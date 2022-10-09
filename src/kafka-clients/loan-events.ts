import {
  Consumer,
  ConsumerConfig,
  Kafka,
  KafkaConfig,
  logCreator,
  Logger,
  EachMessagePayload,
} from "kafkajs"
import apm from "elastic-apm-node"
import camelcaseKeys from "camelcase-keys"
import constants from "../../constants"
import kafkaLogger from "../kafka-logger"
import log from "../../log"
import initConsumer from "../kafka-consumer"
import KafkaOptions from "../../interfaces/kafka-options"
import massageData from "../../massage-data"
import fetchLienHolderId from "../../api/fetch-lien-holder-id"
import FundedLoan from "../../interfaces/funded-loan"

type LienHolder = { id: string; loc_id: string }

type Datum = {
  [name: string]: number | string
}

export default function loanEvents() {
  const kafka = new Kafka({
    clientId: constants.kafkaLoanEventsClientId,
    brokers: [constants.kafkaBootstrapServer],
    sasl: {
      mechanism: "plain",
      username: constants.kafkaApiKey,
      password: constants.kafkaApiSecret,
    },
    ssl: true,
    connectionTimeout: 45000,
  })
  const options = {} as KafkaOptions
  options.kafka = kafka
  options.kafkaGroupId = constants.kafkaLoanEventsGroupId
  options.kafkaTopic = constants.kafkaTopicLoanEvents
  options.poolSize = 4
  options.handler = async function (payload: EachMessagePayload) {
    const trans = apm.startTransaction(
      "Kafka_inbound_message",
      apm.currentTraceparent,
    )
    log.debug(payload.message.value.toString())
    await sendMessage(kafka, payload.message.value.toString())
      .then(() => {
        trans.setOutcome("success")
      })
      .catch((error) => {
        trans.setOutcome("failure")
        log.error(JSON.stringify(error))
        global.isKafkaHealthy = false
      })
    trans.end()
  }
  initConsumer(options)
    .then(() => log.debug(`Started consumer for topic: ${options.kafkaTopic}`))
    .catch((error) => {
      log.error(JSON.stringify(error))
    })
}

async function sendMessage(kafka: Kafka, data: string) {
  // const httpGetSpan = apm.startSpan("Initiate_HTTP_Lienholder_name_request")
  const producer = kafka.producer()
  const lienHolder = (await fetchLienHolderId(
    (JSON.parse(data) as Datum).lienholder_name as string,
  )) as LienHolder
  // httpGetSpan.end()
  const loan: FundedLoan = camelcaseKeys(massageData(data), {
    deep: true,
  })
  if (lienHolder) {
    loan.los.lienHolderId = lienHolder.id
    loan.los.lienHolderLocationId = lienHolder.loc_id
  }
  log.debug(`Formatted loan data: ${JSON.stringify(loan)}`)
  // const producerConnectSpan = apm.startSpan(
  //   "Initiate_Kafka_producer_connection",
  // )
  await producer.connect()
  // producerConnectSpan.end()
  // const producerSendSpan = apm.startSpan("Publish data to Kafka topic")
  await producer.send({
    topic: constants.kafkaTopicNetsuite,
    messages: [{ value: JSON.stringify(loan) }],
  })
  // producerSendSpan.end()
  // const producerdisconnectSpan = apm.startSpan("Publish data to Kafka topic")
  await producer.disconnect()
  // producerdisconnectSpan.end()
}
