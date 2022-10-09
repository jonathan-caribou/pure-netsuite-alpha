import Data.Maybe (fromMaybe)
import Log
import Control.Monad.Except (ExceptT(ExceptT), liftIO)

-- | A function that takes a 'Log.Level' and a log message and outputs
--   a log message.
type Logger = Log.Level -> String -> IO ()

-- | A function that creates a logger that outputs kafka log messages.
kafkaLogger :: Logger
kafkaLogger level message = do
  let logFunc =
        case level of
          Log.LevelDebug -> Log.debug
          Log.LevelInfo -> Log.info
          Log.LevelWarn -> Log.warn
          Log.LevelError -> Log.error
          Log.LevelNothing -> Log.info
          _ -> Log.warn
  logFunc message $ "unknown kafka log level: " <> show logLevel
