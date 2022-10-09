
import Pux
import Effect (Effect)
import Node.PG (Client, connect, query)
import Node.PG.Config (Config(..))
import Node.PG.Types (Connect)
import Node.Process (log)

newtype LogDatabase = LogDatabase Client

instance Show LogDatabase where
  show (LogDatabase client) = "LogDatabase " <> show client

instance Eq LogDatabase where
  (LogDatabase client1) == (LogDatabase client2) =
    client1 == client2

-- | Creates a new `LogDatabase`
newLogDatabase :: Effect LogDatabase
newLogDatabase = do
  let
    config =
      Config
        { user     = "postgres"
        , host     = "localhost"
        , database = "nsevents"
        , password = "postgres"
        , port     = 5432
        }

  client <- connect config

  pure (LogDatabase client)

-- | Initializes the database, creating the `ns_logs` table if it does not already exist
initDatabase :: LogDatabase -> Effect LogDatabase
initDatabase (LogDatabase client) = do
  buildFromSchema client

  pure (LogDatabase client)

-- | Logs an event to the database
logToDatabase :: LogDatabase -> Int -> String -> String -> Effect ()
logToDatabase (LogDatabase client) mrId formattedData message = do
  query client
    "INSERT INTO ns_logs (created_at, mr_id, raw_data, message) VALUES (NOW(), $1, $2, $3);"
    (mrId, formattedData, message)

-- | Gets all logs for a given merge request ID
getLogs :: LogDatabase -> Int -> Effect [String]
getLogs (LogDatabase client) mrId = do
  query client
    "SELECT * FROM ns_logs WHERE mr_id = $1"
    (Only mrId)

-- | Creates the `ns_logs` table if it does not already exist
buildFromSchema :: Client -> Effect ()
buildFromSchema client = do
  query client
    "CREATE TABLE IF NOT EXISTS ns_logs ( id serial PRIMARY KEY, created_at timestamp, mr_id integer, raw_data jsonb, message text );"
    ()

main = do
  logDatabase <- newLogDatabase
  logDatabase' <- initDatabase logDatabase

  logToDatabase logDatabase' 1 "formattedData" "message"

  logs <- getLogs logDatabase' 1

  log $ show logs
