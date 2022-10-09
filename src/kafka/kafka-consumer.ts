import KafkaOptions from "../interfaces/kafka-options"
import log from "../log"
import massageData from "../massage-data"
import { sendFundedLoan } from "../api/send-funded-loan"

export default async function initConsumer(options: KafkaOptions) {
  const consumer = options.kafka.consumer({ groupId: options.kafkaGroupId })
  const { STOP, CRASH, CONNECT } = consumer.events
  consumer.on(CONNECT, (message) => {
    log.debug(`Kafka consumer for topic: ${options.kafkaTopic} connected`)
    global.isKafkaHealthy = true
  })
  consumer.on(CRASH, (error) => {
    log.error(
      `Kafka consumer for topic: ${
        options.kafkaTopic
      } crashed due to ${JSON.stringify(error)}`,
    )
    global.isKafkaHealthy = false
  })
  consumer.on(STOP, (error) => {
    log.error(
      `Kafka consumer for topic: ${
        options.kafkaTopic
      } stopped due to ${JSON.stringify(error)}`,
    )
    global.isKafkaHealthy = false
  })
  await consumer.connect()
  await consumer.subscribe({ topic: options.kafkaTopic })

  await consumer
    .run({
      partitionsConsumedConcurrently: options.poolSize,
      eachMessage: options.handler,
    })
    .catch((error) => {
      log.error(JSON.stringify(error))
    })
    .then((data) => log.debug(data))
}
