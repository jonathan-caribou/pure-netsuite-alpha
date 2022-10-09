import pino, { LoggerOptions } from "pino"
import ecsFormat from "@elastic/ecs-pino-format"

// Pino setup
const loggerOptions: LoggerOptions = ecsFormat()
loggerOptions.level = "debug"

export default pino(loggerOptions)
