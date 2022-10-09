module Environment
  ( isDevelopment
  , isTest
  , isProduction
  , host
  , port
  , oauthSecret
  , oauthKey
  , oauthToken
  , oauthTokenSecret
  , oauthRealm
  , rollbarToken
  , slackToken
  , slackChannelNetsuite
  , sendgridApiKey
  , emailRecipients
  , kafkaBootstrapServer
  , kafkaApiKey
  , kafkaApiSecret
  , kafkaLoanEventsGroupId
  , kafkaNetsuiteOutboundGroupId
  , kafkaTopicLoanEvents
  , kafkaTopicNetsuite
  , kafkaLoanEventsClientId
  , kafkaNetsuiteOutboundClientId
  , logsApiKey
  , host
  ) where

import Prelude (($), String,error)
import Dotenv.Config as Config

--| This value maps to `CONSUMER SECRET / CLIENT SECRET` in the documentation from CTR
oauthSecret :: String
oauthSecret = processEnv "NETSUITE_OAUTH_SECRET"

--| This value maps to `CONSUMER KEY / CLIENT ID` in the documentation from CTR
oauthKey :: String
oauthKey = processEnv "NETSUITE_OAUTH_KEY"

--| This value maps to `TOKEN ID` in the documentation from CTR
oauthToken :: String
oauthToken = processEnv "NETSUITE_OAUTH_TOKEN"

--| This value maps to `TOKEN SECRET` in the documentation from CTR
oauthTokenSecret :: String
oauthTokenSecret = processEnv "NETSUITE_OAUTH_TOKEN_SECRET"

oauthRealm :: String
oauthRealm = processEnv "NETSUITE_OAUTH_REALM"

rollbarToken :: Maybe String
rollbarToken = processEnvMaybe "ROLLBAR_TOKEN"

slackToken :: Maybe String
slackToken = processEnvMaybe "SLACK_TOKEN"

slackChannelNetsuite :: Maybe String
slackChannelNetsuite = processEnvMaybe "SLACK_CHANNEL_NETSUITE"

logsApiKey :: Maybe String
logsApiKey = processEnvMaybe "LOGS_API_KEY"

logsApiKey :: Maybe String
logsApiKey = processEnvMaybe "HOST"

kafkaBootstrapServer :: String
kafkaBootstrapServer = fromMaybe "pkc-419q3.us-east4.gcp.confluent.cloud:9092" $ processEnvMaybe "KAFKA_BOOTSTRAP_SERVER"

kafkaApiKey :: String
kafkaApiKey = processEnv "KAFKA_API_KEY"

kafkaApiSecret :: String
kafkaApiSecret = processEnv "KAFKA_API_SECRET"

kafkaLoanEventsGroupId :: String
kafkaLoanEventsGroupId = fromMaybe "loan-events" $ processEnvMaybe "KAFKA_LOAN_EVENTS_GROUP_ID"

kafkaNetsuiteOutboundGroupId :: String
kafkaNetsuiteOutboundGroupId = fromMaybe "netsuite-outbound" $ processEnvMaybe "KAFKA_NETSUITE_OUTBOUND_GROUP_ID"

kafkaTopicNetsuite :: String
kafkaTopicNetsuite = fromMaybe "ext-netsuite-outbound" $ processEnvMaybe "KAFKA_TOPIC_NETSUITE"

kafkaTopicLoanEvents :: String
kafkaTopicLoanEvents = fromMaybe "loan-events" $ processEnvMaybe "KAFKA_TOPIC_LOAN_EVENTS"

kafkaLoanEventsClientId :: String
kafkaLoanEventsClientId = fromMaybe "loan-events" $ processEnvMaybe "KAFKA_LOAN_EVENTS_CLIENT_ID"

kafkaNetsuiteOutboundClientId :: String
kafkaNetsuiteOutboundClientId = fromMaybe "netsuite-outbound" $ processEnvMaybe "KAFKA_NETSUITE_OUTBOUND_CLIENT_ID"

host :: String
host = fromMaybe "localhost" $ processEnvMaybe "HOST_IP"

port :: String
port = fromMaybe "8000" $ processEnvMaybe "HOST_PORT"

sendgridApiKey :: Maybe String
sendgridApiKey = processEnvMaybe "SENDGRID_API_KEY"

emailRecipients :: Maybe String
emailRecipients = processEnvMaybe "EMAIL_RECIPIENTS"

processEnv :: String -> String
processEnv variableName =
  let env = Env.getEnv variableName
  in maybe (error $ variableName <> " is not set") id env

processEnvMaybe :: String -> Maybe String
processEnvMaybe variableName =
  Env.lookupEnv variableName


-- Due to the difference between Node's `process.env` and GHC's `Env.getEnv` we need two
-- different functions to get environment variables. The `is*` functions will use
-- Node's `process.env` while the other functions will use GHC's `Env.getEnv`. 

isDevelopment :: Bool
isDevelopment = processEnv "NODE_ENV" == "development"

isTest :: Bool
isTest = processEnv "NODE_ENV" == "test"

isProduction :: Bool
isProduction = processEnv "NODE_ENV" == "production"