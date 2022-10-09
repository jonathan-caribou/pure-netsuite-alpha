import { logLevel } from "kafkajs"
import log from "../log"

export default function kafkaLogger() {
  return (level: logLevel) => (message: unknown) => {
    switch (level) {
      case logLevel.DEBUG:
        log.debug(message)
        break

      case logLevel.INFO:
      case logLevel.NOTHING:
        log.info(message)
        break

      case logLevel.WARN:
        log.warn(message)
        break

      case logLevel.ERROR:
        log.error(message)
        break

      default:
        log.warn(message, `unknown kafka log level: ${String(logLevel)}`)
        break
    }
  }
}
