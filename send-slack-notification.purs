
import Prelude
import Slack.WebAPI as Slack
import Constants as Constants
import Log as Log

sendSlackNotification :: String -> String -> Effect Unit
sendSlackNotification message channel = do
  let options = { token: Constants.slackToken }
  web <- Slack.init options

  result <- Slack.chatPostMessage web { text: message, channel }

  Log.debug $ "Successfully send message " <> result#toLogStr <> " in conversation " <> channel