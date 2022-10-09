import "dotenv/config"

// This value maps to `CONSUMER SECRET / CLIENT SECRET` in the documentation from CTR
const oauthSecret = process.env.NETSUITE_OAUTH_SECRET
// This value maps to `CONSUMER KEY / CLIENT ID` in the documentation from CTR
const oauthKey = process.env.NETSUITE_OAUTH_KEY
// This value maps to `TOKEN ID` in the documentation from CTR
const oauthToken = process.env.NETSUITE_OAUTH_TOKEN
// This value maps to `TOKEN SECRET` in the documentation from CTR
const oauthTokenSecret = process.env.NETSUITE_OAUTH_TOKEN_SECRET
const oauthRealm = process.env.NETSUITE_OAUTH_REALM
const rollbarToken = process.env.ROLLBAR_TOKEN
const slackToken = process.env.SLACK_TOKEN
const slackChannelNetsuite = process.env.SLACK_CHANNEL_NETSUITE
const logsApiKey = process.env.LOGS_API_KEY
const kafkaBootstrapServer =
  process.env.KAFKA_BOOTSTRAP_SERVER ??
  "pkc-419q3.us-east4.gcp.confluent.cloud:9092"
const kafkaApiKey = process.env.KAFKA_API_KEY
const kafkaApiSecret = process.env.KAFKA_API_SECRET
const kafkaLoanEventsGroupId =
  process.env.KAFKA_LOAN_EVENTS_GROUP_ID ?? "loan-events"
const kafkaNetsuiteOutboundGroupId =
  process.env.KAFKA_NETSUITE_OUTBOUND_GROUP_ID ?? "netsuite-outbound"
const kafkaTopicNetsuite =
  process.env.KAFKA_TOPIC_NETSUITE ?? "ext-netsuite-outbound"
const kafkaTopicLoanEvents =
  process.env.KAFKA_TOPIC_LOAN_EVENTS ?? "loan-events"
const kafkaLoanEventsClientId =
  process.env.KAFKA_LOAN_EVENTS_CLIENT_ID ?? "loan-events"
const kafkaNetsuiteOutboundClientId =
  process.env.KAFKA_NETSUITE_OUTBOUND_CLIENT_ID ?? "netsuite-outbound"
const host = process.env.HOST_IP ?? "localhost"
const port = process.env.HOST_PORT ?? "8000"
const sendgridApiKey = process.env.SENDGRID_API_KEY
const emailRecipients = process.env.EMAIL_RECIPIENTS

if (!oauthSecret) {
  throw new Error("environment variable NETSUITE_OAUTH_SECRET is not set")
}

if (!oauthKey) {
  throw new Error("environment variable NETSUITE_OAUTH_KEY is not set")
}

if (!oauthToken) {
  throw new Error("environment variable NETSUITE_OAUTH_TOKEN is not set")
}

if (!oauthTokenSecret) {
  throw new Error("environment variable NETSUITE_OAUTH_TOKEN_SECRET is not set")
}

if (!oauthRealm) {
  throw new Error("environment variable NETSUITE_OAUTH_REALM is not set")
}

if (!kafkaApiKey) {
  throw new Error("environment variable KAFKA_API_KEY is not set")
}

if (!kafkaApiSecret) {
  throw new Error("environment variable KAFKA_API_SECRET is not set")
}

export default {
  isDevelopment: process.env.NODE_ENV === "development",
  isTest: process.env.NODE_ENV === "test",
  isProduction: process.env.NODE_ENV === "production",
  host,
  port,
  oauthSecret,
  oauthKey,
  oauthToken,
  oauthTokenSecret,
  oauthRealm,
  rollbarToken,
  slackToken,
  slackChannelNetsuite,
  sendgridApiKey,
  emailRecipients,
  kafkaBootstrapServer,
  kafkaApiKey,
  kafkaApiSecret,
  kafkaLoanEventsGroupId,
  kafkaNetsuiteOutboundGroupId,
  kafkaTopicLoanEvents,
  kafkaTopicNetsuite,
  kafkaLoanEventsClientId,
  kafkaNetsuiteOutboundClientId,
  logsApiKey,
}
