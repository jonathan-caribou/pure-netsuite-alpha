import { Kafka, EachMessageHandler } from "kafkajs"

export default interface KafkaOptions {
  kafka: Kafka
  kafkaGroupId: string
  kafkaTopic: string
  poolSize: number
  handler: EachMessageHandler
}
