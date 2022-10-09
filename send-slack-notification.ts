import { WebClient, WebClientOptions } from "@slack/web-api"
import constants from "./constants"
import log from "./log"

export default async function sendSlackNotification(
  message: string,
  channel: string,
) {
  class Options implements WebClientOptions {}

  const web = new WebClient(constants.slackToken, new Options())
  const result = await web.chat.postMessage({
    text: message,
    channel,
  })

  // The result contains an identifier for the message, `ts`.
  log.debug(`Successfully send message ${result.ts} in conversation ${channel}`)
}
