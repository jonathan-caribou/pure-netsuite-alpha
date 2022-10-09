import Api.Elastic.Apm
import Control.Monad.Except
import Control.Monad.Reader
import Data.Function ((&))
import Data.Maybe (fromMaybe)
import Network.HTTP.Client (Manager)
import Network.HTTP.Types.Status (statusCode)
import Network.Wai (Application)
import Network.Wai.Handler.Warp (run)
import Network.Wai.Middleware.RequestLogger (logStdoutDev)
import System.Environment (lookupEnv)
import System.Log.FastLogger (LoggerSet, newStdoutLoggerSet, toLogStr)

import qualified Control.Concurrent as CC
import qualified Control.Exception as CE
import qualified Data.Text as T
import qualified Network.Kafka as Kafka
import qualified Network.Kafka.Consumer as Consumer
import qualified Network.Kafka.Producer as Producer
import qualified Network.Kafka.Types as Kafka

import Constants (kafkaBrokers, kafkaLogsTopic, kafkaNetsuiteOutboundTopic, logsApiKey, port, topicLoanEvents)
import Log (logDebug, logError, logInfo)
import Kafka.KafkaClients.ExternalNetsuiteOutbound (externalNetsuiteOutbound)
import Kafka.KafkaClients.LoanEvents (loanEvents)
import LogDatabase (LogDatabase, getLogs, initDatabase)

main :: IO ()
main = do
  logInfo "Starting Logs API..."

  let settings =
        setPort (fromMaybe port $ read <$> lookupEnv "PORT") $
        setBeforeMainLoop (beforeMainLoop logInfo) $
        defaultSettings

  runSettings settings app

app :: Application
app = logStdoutDev $ \req sendResponse -> do
  let params =
        req
          & requestHeaders
          & lookup "Authorization"
          & fmap T.decodeUtf8
          & fromMaybe ""

  if params /= logsApiKey
    then do
      logDebug $ "Invalid API key: " <> params
      sendResponse $ responseLBS status403 [] "FORBIDDEN"
    else do
      let mrId =
            req
              & pathInfo
              & head
              & T.decodeUtf8
              & T.unpack
              & read
              & fromMaybe (-1)

      if mrId == -1
        then do
          logDebug $ "Invalid MR ID: " <> T.pack (show mrId)
          sendResponse $ responseLBS status400 [] "BAD REQUEST"
        else do
          logDatabase <- LogDatabase <$> initDatabase
          logs <- runExceptT $ getLogs logDatabase mrId
          case logs of
            Left err -> do
              logError $ "Error getting logs: " <> T.pack (show err)
              sendResponse $ responseLBS status500 [] "INTERNAL SERVER ERROR"
            Right rows -> do
              logDebug $ "Successfully retrieved logs for MR ID: " <> T.pack (show mrId)
              sendResponse $ responseLBS status200 [] (encode rows)

beforeMainLoop :: (T.Text -> IO ()) -> IO ()
beforeMainLoop logFn = do
  logFn "Initializing Kafka clients..."

  CC.forkIO $ CE.catch (loanEvents & runReaderT) (\(err :: CE.SomeException) -> logError $ "Error initializing Loan Events Kafka client: " <> T.pack (show err))
  CC.forkIO $ CE.catch (externalNetsuiteOutbound & runReaderT) (\(err :: CE.SomeException) -> logError $ "Error initializing External Netsuite Outbound Kafka client: " <> T.pack (show err))

  logFn "Successfully initialized Kafka clients"

initDatabase :: IO (Manager)
initDatabase = do
  logInfo "Initializing database..."

  let settings =
        setPort (fromMaybe port $ read <$> lookupEnv "PORT") $
        setBeforeMainLoop (beforeMainLoop logInfo) $
        defaultSettings

  runSettings settings app

  logInfo "Successfully initialized database"