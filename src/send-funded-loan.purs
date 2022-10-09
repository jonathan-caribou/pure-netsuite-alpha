
-- 🔎 Simple HTTP client for sending HTTP requests and receiving responses
import Network.HTTP.Simple (httpLbs, setRequestBodyJSON, setRequestMethod, setRequestHeader) 

-- 📦 A type representing the constants defined in the application
import Constants (slackChannelNetsuite) 

-- 🎬 Function lifting
import Control.Monad.Trans.Class (lift) 

-- 🚧 The ExceptT monad transformer
import Control.Monad.Trans.Except (ExceptT(ExceptT), runExceptT) 

-- 🚦 The ReaderT monad transformer
import Control.Monad.Trans.Reader (ReaderT(ReaderT), runReaderT) 

-- 📨 Aencode values to JSON and decode values from JSON
import Data.Aeson (encode) 

-- 🌈 A type class for types that can be folded
import Data.Foldable (for_) 

-- 🔗 The (.) function, which composes functions
import Data.Function ((&)) 

-- 📦 A type representing lists
import Data.List ((++)) 

-- 💾 A type representing optional values
import Data.Maybe (fromJust) 

-- 🔠 A type class for converting values to strings
import Data.String (fromString) 

-- 📜 A type representing Unicode character strings
import Data.Text (unpack) 

-- 🔬 A function for tracing program execution
import Debug.Trace (trace) 

-- 🏗 A monad for asynchronous, concurrent and safe program execution
import Effect (Effect) 

-- 🚴 An HTTP client engine
import Network.HTTP.Client (Manager) 

-- 📪 A type representing the methods used in HTTP requests
import Network.HTTP.Types.Method (methodPost) 

-- 📩 A status code indicating the success or failure of an HTTP request
import Network.HTTP.Types.Status (status200, statusCode) 

-- ✉️ A type representing the headers used in HTTP requests
import Network.HTTP.Types.Header (hContentType) 

-- 📍 A type representing the URI components used in HTTP requests
import Network.HTTP.Types.URI (urlEncode) 
-- 🔀 A type representing a URI
import Network.URI (parseURI, URI(URI), uriQuery, uriToString) 
-- 📦 A type representing URI components
import Network.URI.Component (componentDecode, Component(..)) 
-- 🌟 The Prelude, a standard module imported by default into all Purescript modules
import Prelude

-- 🗄️ A module for logging events to a database
import LogDatabase (logToDatabase)


-- 🔁 Retry failed requests using the Axios library
axiosRetry :: httpClient -> { retries: 4, retryDelay: (retryCount) =>
 { return axiosRetry.exponentialDelay(retryCount) }, onRetry: ( retryCount: number, error: AxiosError, request: AxiosRequestConfig, ) => { log.error(`💀 Failed to load loan to netsuite error: ${error.message} retry count: ${retryCount}. Retrying the loan: ${loans[0].los.sourceSystemId}`, ), log.debug(`Loan details for the failed request: ${JSON.stringify(request.data)}`, ), }, }

-- 🌐 Function for making HTTP requests using the Axios library
httpClient :: Manager -> Config -> Client a
httpClient manager config = Client $ \req -> do
  let baseUrl = configNetsuiteUrl config
  let url = baseUrl ++ reqUrl req
  let headers =
        fromList
          [ ("Authorization", "Bearer " ++ configNetsuiteToken config)
          , ("Accept", "application/json")
          , ("Content-Type", "application/json")
          ]
      req' =
        req
          { method = "POST"
          , manager = manager
          , checkResponse = \_ _ -> return ()
          , responseTimeout = responseTimeoutNone
          , redirectCount = 10
          , requestHeaders = headers
          }
  httpLbs req' manager

-- 🔁 Function for making HTTP requests using the Axios library with retry
axios :: (MonadIO m, MonadReader r m, Has Axios r) => AxiosRequest -> m (Either String (Response BodyReader))
axios req = do
  axios <- view axiosL
  liftIO $ runExceptT $ ExceptT $ request axios req

-- 🔁 Function for making HTTP requests using the Axios library with retry
retry :: (MonadIO m, MonadReader r m, Has Axios r) => RetryOptions -> AxiosRequest -> m (Either String (Response BodyReader))
retry options req = do
  axios <- view axiosL
  liftIO $ runExceptT $ ExceptT $ request (axios & interceptorsRetry options) req

-- 🌐 Function for making HTTP requests using the Axios library
request :: Axios -> AxiosRequest -> IO (Either String (Response BodyReader))
request axios req = do
  res <- liftIO $ runExceptT $ ExceptT $ httpLbs req axios
  return $ fmap (fmap responseBody) res