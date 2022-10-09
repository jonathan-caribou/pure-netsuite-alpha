import { Kafka, Message, EachMessagePayload } from "kafkajs"
import apm from "elastic-apm-node"
import camelcaseKeys from "camelcase-keys"
import constants from "../../constants"
import KafkaOptions from "../../interfaces/kafka-options"
import kafkaLogger from "../kafka-logger"
import log from "../../log"
import initConsumer from "../kafka-consumer"
import sendFundedLoan from "../../api/send-funded-loan"
import FundedLoan from "../../interfaces/funded-loan"

export default function externalNetsuiteOutbound() {
  const kafka = new Kafka({
    clientId: constants.kafkaNetsuiteOutboundClientId,
    brokers: [constants.kafkaBootstrapServer],
    logCreator: kafkaLogger(),
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
  options.kafkaGroupId = constants.kafkaNetsuiteOutboundGroupId
  options.kafkaTopic = constants.kafkaTopicNetsuite
  options.poolSize = 5
  options.handler = async function (payload: EachMessagePayload) {
    const trans = apm.startTransaction(
      "Kafka_outbound_message",
      apm.currentTraceparent,
    )
    const output = camelcaseKeys(JSON.parse(payload.message.value.toString()), {
      deep: true,
    }) as unknown as FundedLoan
    await sendFundedLoan([output])
      .then(() => {
        trans.setOutcome("success")
      })
      .catch(() => {
        trans.setOutcome("failure")
      })

    trans.end()
  }
  initConsumer(options)
    .then(() => log.debug(`Started consumer for topic: ${options.kafkaTopic}`))
    .catch((error) => {
      log.error(JSON.stringify(error))
    })
}
