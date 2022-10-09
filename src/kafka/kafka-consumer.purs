import Prelude
import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Monad.Log (Log, log)
import Data.Kafka (Consumer, events, runConsumer)
import Data.Maybe (fromMaybe)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Uncurried (mkEffectFn_)

-- The KafkaOptions type defines the options that can be passed into the initConsumer function
type KafkaOptions = { kafka :: Consumer, kafkaGroupId :: String, kafkaTopic :: String }

-- The logMessage function takes a string and logs it to the console
logMessage :: forall e. String -> Aff (log :: Log | e) Unit
logMessage msg = liftEffect do
  log $ "Kafka consumer for topic: " <> msg <> " connected"

-- The handler function takes care of consuming messages from a Kafka topic
handler :: forall e. (KafkaOptions -> Object -> Aff (kafka :: Kafka | e) Unit) -> KafkaOptions -> Object -> Aff (kafka :: Kafka | e) Unit
handler options = do
  let topic = options.kafkaTopic
  logMessage $ "Kafka consumer for topic: " <> topic <> " connected"
  runConsumer options.kafka options.kafkaGroupId topic options.poolSize

-- The initConsumer function initializes a Kafka consumer
initConsumer :: forall e. KafkaOptions -> Aff (kafka :: Kafka | e) Unit
initConsumer =
  let connect = events.CONNECT
      crash   = events.CRASH
      stop    = events.STOP
  in  \ options -> do
        let kafka = options.kafka
            groupId = options.kafkaGroupId
        kafka.on(connect, logMessage("connected"))
        kafka.on(crash, \ error -> logMessage("crashed due to " <> error))
        kafka.on(stop, \ error -> logMessage("stopped due to " <> error))
        kafka.connect()
        kafka.subscribe({ topic: options.kafkaTopic })
        kafka.run({ partitionsConsumedConcurrently: options.poolSize, eachMessage: handler(options) })
        .catch(\ error -> logMessage(error))
        .then(\ data -> logMessage(data))

-- The initConsumer_ function takes care of initializing a Kafka consumer
initConsumer_ :: forall e. KafkaOptions -> Eff (kafka :: Kafka | e) Unit
initConsumer_ = mkEffectFn_ initConsumer

-- This is the main function that runs the Kafka consumer
main = do
  let options = { kafka: undefined, kafkaGroupId: "my-group", kafkaTopic: "my-topic" }
  initConsumer_ options