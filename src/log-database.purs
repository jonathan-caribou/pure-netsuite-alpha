import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (log)
import Control.Monad.Eff.Exception (try)
import Control.Monad.Eff.Ref (newRef, modifyRef, readRef)
import Data.Time.Clock (getCurrentTime)
import Data.Time.Format (formatTime, defaultTimeLocale)
import Network.HTTP.Req ((/:), HttpConfig, Scheme(Http), defaultHttpConfig, req, reqBodyJson, responseBody, runReq)
import System.Environment (lookupEnv)
import System.Random (randomRIO)

type PGClient = Client
type DbConfig = { user :: String, host :: String, database :: String, password :: String, port :: Int }

newtype LogDatabase = LogDatabase (PGClient Eff)

initDatabase :: forall eff. DbConfig -> Eff (log :: LOG | eff) LogDatabase
initDatabase config = do
  log "create db client"
  client <- connect config
  log "build from schema"
  _ <- buildFromSchema client
  log "done initializing db"
  pure (LogDatabase client)

logToDatabase :: forall eff. LogDatabase -> Int -> String -> Eff (log :: LOG | eff) Unit
logToDatabase (LogDatabase client) mrId formattedData = do
  now <- liftEff $ getCurrentTime
  _ <- liftEff $ run client $ query client queryText
  pure unit
  where
    queryText =
      "INSERT INTO ns_logs (created_at, mr_id, raw_data,  message) VALUES (?, ?, ?, ?);"

getLogs :: forall eff. LogDatabase -> Int -> Eff (log :: LOG | eff) Unit
getLogs (LogDatabase client) mrId = do
  _ <- liftEff $ run client $ query client queryText
  pure unit
  where
    queryText = "SELECT * FROM ns_logs WHERE mr_id = ?"

buildFromSchema :: forall eff. PGClient Eff -> Eff (log :: LOG | eff) Unit
buildFromSchema client = do
  _ <- liftEff $ run client $ query client queryText
  pure unit
  where
    queryText =
      "CREATE TABLE IF NOT EXISTS ns_logs ( \
      \  id serial PRIMARY KEY, \
      \  created_at timestamp, \
      \  mr_id integer, \
      \  raw_data jsonb, \
      \  message text \
      \);"

connect :: forall eff. DbConfig -> Eff (log :: LOG | eff) (PGClient Eff)
connect config = do
  client <- liftEff $ P.connect config
  _ <- liftEff $ P.execute_ client "SET search_path TO ns_logs, public;"
  pure client

run :: forall eff a. PGClient Eff -> PG.Query a -> Eff (log :: LOG | eff) a
run client query = liftEff $ P.execute client query ()

query :: forall eff a. PGClient Eff -> PG.Query a -> Eff (log :: LOG | eff) [a]
query client query = liftEff $ P.query client query ()

liftEff :: forall eff a. Eff (log :: LOG | eff) a -> Eff eff a
liftEff = id

unit :: Unit
unit = Unit

main :: Eff (console :: CONSOLE, db :: grownup-postgres-client | eff) Unit
main = do
  -- First we'll fetch the environment variables we need to connect
  -- to Postgres
  log "Fetching environment variables"

  dbUser <- lookupEnv "DATABASE_USER"
  dbHost <- lookupEnv "DATABASE_HOST"
  dbPassword <- lookupEnv "DATABASE_PASSWORD"
  dbPortStr <- lookupEnv "DATABASE_PORT"
  let dbPort = read dbPortStr

  -- If any of the environment variables are missing, we'll throw an error
  when (isNothing dbUser || isNothing dbHost || isNothing dbPassword || isNothing dbPortStr) $ do
    log "Missing environment variables, cannot continue"
    throw "Missing environment variables"

  let config = DbConfig
        { user = fromJust dbUser
        , host = fromJust dbHost
        , database = "nsevents"
        , password = fromJust dbPassword
        , port = dbPort
        }

  -- Now we can initialize our database connection
  db <- initDatabase config

  -- And finally we can log something to the database!
  logToDatabase db 1 "This is a test log message"