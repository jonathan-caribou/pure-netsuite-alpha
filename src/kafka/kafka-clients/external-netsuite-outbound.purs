-- 💻 | This library provides functions for working with the PureScript language.
import Prelude

-- 🔢 | The Control.Monad.Except module provides functions for working with monadic values
-- 🛑 | that may throw exceptions.
import Control.Monad.Except (ExceptT(ExceptT), runExceptT)

-- 📖 | The Control.Monad.Reader module provides functions for working with monadic values
-- 🔗 | that can read from a shared environment.
import Control.Monad.Reader (ReaderT(ReaderT), runReaderT)

-- 🌐 | The Data.Bifunctor module provides functions for working with data structures
-- 🌍 | that can be mapped over in two ways.
import Data.Bifunctor (first)

-- ✅ | The Data.Either module provides functions for working with values of type 'Either'.
import Data.Either (Either(Left, Right))

-- ⚙️ | The Data.Function module provides functions for working with functions.
import Data.Function (($), (.), const, id)

-- ♻️ | The Data.Functor module provides functions for working with functors.
import Data.Functor ((<$>))

-- 🤷 | The Data.Maybe module provides functions for working with values of type 'Maybe'.
import Data.Maybe (Maybe(Just, Nothing))

-- 📝 | The Data.String module provides functions for working with strings.
import Data.String (String)

-- 🚶‍♂️ | The Data.Traversable module provides functions for working with data structures
-- 🚶‍♀️ | that can be traversed in a variety of ways.
import Data.Traversable (for)

-- 🎆 | The Effect module provides functions for working withEffect values.
import Effect (Effect)

-- 🌐 | The Node.HTTP module provides functions for working with HTTP requests and responses.
import Node.HTTP (request)

-- 📦 | The Node.HTTP.Body module provides functions for working withHTTP request and
-- 📦 | response bodies.
import Node.HTTP.Body (jsonBody)

-- 🔨 | The Node.HTTP.Method module provides functions for working with HTTP methods.
import Node.HTTP.Method (Method(POST))

-- 📧 | The Node.HTTP.Request module provides functions for working with HTTP requests.
import Node.HTTP.Request (Request(requestWith))

-- 📬 | The Node.HTTP.Response module provides functions for working with HTTP responses.
import Node.HTTP.Response (Response)

-- 🔢 | The Node.HTTP.Status module provides functions for working with HTTP status codes.
import Node.HTTP.Status (Status)

-- 🌐 | The Node.HTTP.URL module provides functions for working with URLs.
import Node.HTTP.URL (URL, baseUrl)

-- 📝 | The Node.Logger module provides functions for logging messages.
import Node.Logger (LogLevel(Error, Info), log)

-- ⏰ | The Node.Timeout module provides functions for working with timeouts.
import Node.Timeout (timeout)

-- ⏳ | The Node.Time module provides functions for working with time.
import Node.Time (TimeUnit(Seconds))

-- 🚀 | The Record.Unsafe module provides functions for working with Records without
-- 🚫 | safety checks.
import Record.Unsafe (unsafeGet)

-- 🎲 | The System.Random module provides functions for working with random values.
import System.Random (randomRIO)
-- Connect to the external Kafka server.
connectToKafka :: Kafka -> Effect Unit
connectToKafka = log "Kafka connected." Info

-- | Function that initializes a Kafka consumer.
initConsumer :: KafkaOptions -> Effect Unit
initConsumer options = do
  log "Starting Kafka consumer." Info
  connectToKafka $ kafka options
  log "Initialized Kafka consumer." Info

-- | Function that handles messages received from Kafka.
handleMessage :: EachMessagePayload -> Effect Unit
handleMessage payload = do
  let output = camelcaseKeys $ jsonBody $ message payload
  _ <- timeout $ sendFundedLoan [output]
  log "Sent loan to NetSuite." Info

-- | Function that sends a loan to NetSuite.
sendFundedLoan :: [FundedLoan] -> Effect Unit
sendFundedLoan loans = do
  baseUrl <- baseUrl <$> randomRIO ("https://", "https://")
  for loans $ \loan -> do
    response <- requestWith baseUrl $ request {
      method = POST,
      path = "/service/rest/v1/funded-loans",
      headers = ["Content-Type"::String, "Accept"::String],
      body = jsonBody loan
    }
    case response of
      Left err -> log (show err) Error
      Right res -> do
        status <- status res
        if status == 200
          then log "Sent loan to NetSuite." Info
          else log "Error sending loan to NetSuite." Error

-- | Function that reads messages from Kafka and passes them to the message
-- handler.
readFromKafka :: KafkaOptions -> Effect Unit
readFromKafka options = do
  log "Reading from Kafka." Info
  messages <- kafkaConsumer options
  for messages $ \payload -> do
    _ <- timeout $ handleMessage payload
    log "Handled message." Info
  log "Finished reading from Kafka." Info

-- | Function that starts the external Kafka consumer.
externalNetsuiteOutbound :: Effect Unit
externalNetsuiteOutbound = do
  initConsumer $ KafkaOptions {
    kafka = Kafka {
      clientId = "kafka-netsuite-outbound-consumer",
      brokers = ["kafka-bootstrap-server"],
      logCreator = kafkaLogger,
      sasl = Just $ Sasl {
        mechanism = "plain",
        username = "kafka-api-key",
        password = "kafka-api-secret"
      },
      ssl = True,
      connectionTimeout = 45000
    },
    kafkaGroupId = "kafka-netsuite-outbound-group",
    kafkaTopic = "kafka-topic-netsuite",
    poolSize = 5,
    handler = \payload -> do
      let output = camelcaseKeys $ jsonBody $ message payload
      _ <- timeout $ sendFundedLoan [output]
      log "Sent loan to NetSuite." Info
  }
  log "Started consumer for topic: kafka-topic-netsuite" Info
  readFromKafka $ KafkaOptions {
    kafka = Kafka {
      clientId = "kafka-netsuite-outbound-consumer",
      brokers = ["kafka-bootstrap-server"],
      logCreator = kafkaLogger,
      sasl = Just $ Sasl {
        mechanism = "plain",
        username = "kafka-api-key",
        password = "kafka-api-secret"
      },
      ssl = True,
      connectionTimeout = 45000
    },
    kafkaGroupId = "kafka-netsuite-outbound-group",
    kafkaTopic = "kafka-topic-netsuite",
    poolSize = 5,
    handler = \payload -> do
      let output = camelcaseKeys $ jsonBody $ message payload
      _ <- timeout $ sendFundedLoan [output]
      log "Sent loan to NetSuite." Info
  }
  log "Reading from Kafka." Info
  messages <- kafkaConsumer $ KafkaOptions {
    kafka = Kafka {
      clientId = "kafka-netsuite-outbound-consumer",
      brokers = ["kafka-bootstrap-server"],
      logCreator = kafkaLogger,
      sasl = Just $ Sasl {
        mechanism = "plain",
        username = "kafka-api-key",
        password = "kafka-api-secret"
      },
      ssl = True,
      connectionTimeout = 45000
    },
    kafkaGroupId = "kafka-netsuite-outbound-group",
    kafkaTopic = "kafka-topic-netsuite",
    poolSize = 5,
    handler = \payload -> do
      let output = camelcaseKeys $ jsonBody $ message payload
      _ <- timeout $ sendFundedLoan [output]
      log "Sent loan to NetSuite." Info
  }
  for messages $ \payload -> do
    _ <- timeout $ handleMessage payload
    log "Handled message." Info
  log "Finished reading from Kafka." Info
  log "Stopping Kafka consumer." Info