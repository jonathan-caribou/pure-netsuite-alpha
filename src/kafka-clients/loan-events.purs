
-- | 🖨️ This library allows us to use the Console module which lets us print out logs to the console
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)

-- | 💣 This library allows us to use the Exception module which lets us deal with exceptions
import Control.Monad.Eff.Exception (EXCEPTION)

-- | 🤔 This library allows us to use the Either type which is either Left or Right
import Data.Either (Either(Left, Right))

-- | 💰 This library allows us to use the $ operator
import Data.Function (($))

-- | 🎲 This library allows us to use the <$> operator
import Data.Functor ((<$>))

-- | 🤷‍♀️ This library allows us to use the Maybe type which is either Just or Nothing
import Data.Maybe (Maybe(Just, Nothing))

-- | 🔍 This library allows us to use the Proxy type
import Data.Proxy (Proxy(Proxy))

-- | 💥 This library allows us to use the $! operator
import Prelude (($!))

-- | 🚀 This library allows us to use the Elastic APM Node module which lets us use the apm function
import ElasticAPM.Node (apm)

-- | 🐶 This library allows us to use the KafkaJS module
import KafkaJS as Kafka

-- | 📦 This library allows us to use the Avro module which lets us decode and encode Avro messages
import KafkaJS.Avro (decodeAvro, encodeAvro)

-- | 📼 This library allows us to use the Codec module which lets us specify a codec for our messages
import KafkaJS.Codec (Codec)

-- | 🔌 This library allows us to use the Connected module which lets us connect to Kafka
import KafkaJS.Connected (Connected)

-- | 🛒 This library allows us to use the Consumer module which lets us create a ConsumerGroupStream and consume messages from Kafka
import KafkaJS.Consumer (ConsumerGroupStream, eachMessage, initConsumerGroupStream, runConsumerGroupStream)

-- | 🛍 This library allows us to use the ConsumerGroup module which lets us create a ConsumerGroupMemberId and a MemberAssignment
import KafkaJS.ConsumerGroup (ConsumerGroupMemberId(ConsumerGroupMemberId), MemberAssignment, MemberMetadata(MemberMetadata))

-- | ❗️ This library allows us to use the Error module which lets us deal with errors
import KafkaJS.Error (KafkaError(KafkaJSException, ProcessExitFailure))

-- | 📦 This library allows us to use the Producer module which lets us produce messages to Kafka
import KafkaJS.Producer (ProducerRecord(ProducerRecord), produceMessages, runProducer, sendMessage)

-- | 📋 This library allows us to use the Record module which lets us create a RecordMetadata
import KafkaJS.Record (RecordMetadata(RecordMetadata), RecordValue(RecordValue))

-- | 🎲 This library allows us to use the Result module
import KafkaJS.Result (Result)

-- | 📦 This library allows us to use the TopicPartition module which lets us specify a topic and partition
import KafkaJS.TopicPartition (TopicPartition(TopicPartition))
logCreator _ _ = return ()

-- | The type representing a lienholder.
type LienHolder = { id :: String, loc_id :: String }

-- | The type representing a single data element.
type Datum = {
  [name: string]: Int | String
}

loanEvents = do
  kafka <- Kafka.newKafka {
    clientId: constants.kafkaLoanEventsClientId,
    brokers: [constants.kafkaBootstrapServer],
    sasl: {
      mechanism: "plain",
      username: constants.kafkaApiKey,
      password: constants.kafkaApiSecret
    },
    ssl: true,
    connectionTimeout: 45000
  }

  options = {
    kafka: kafka,
    kafkaGroupId: constants.kafkaLoanEventsGroupId,
    kafkaTopic: constants.kafkaTopicLoanEvents,
    poolSize: 4,
    handler: \payload -> do
      log.debug(payload.message.value.toString())
      sendMessage kafka payload.message.value.toString
  }

  initConsumerGroupStream options >>= \case
    Left failure -> log.error(failure.show)
    Right stream -> runConsumerGroupStream stream


-- | Take a message payload containing loan data and send it to the appropriate
-- | topic.
sendMessage kafka data = do
  producer <- Kafka.producer kafka
  Kafka.runProducer producer \p -> do
    lienHolder <- fetchLienHolderId (data.lienholder_name as string)
    let loan: FundedLoan = camelcaseKeys(massageData data, { deep: true })
    if lienHolder
      loan.los.lienHolderId = lienHolder.id
      loan.los.lienHolderLocationId = lienHolder.loc_id
    log.debug(`Formatted loan data: ${JSON.stringify loan}`)
    Kafka.sendMessage p (ProducerRecord {
      topic: constants.kafkaTopicNetsuite,
      messages: [{ value: JSON.stringify loan }],
    })
}

