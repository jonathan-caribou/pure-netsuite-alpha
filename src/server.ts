import apm from "elastic-apm-node"
import http from "node:http"
import constants from "./constants"
import log from "./log"
import loanEvents from "./kafka/kafka-clients/loan-events"
import externalNetsuiteOutbound from "./kafka/kafka-clients/external-netsuite-outbound"
import { LogDatabase } from "./log-database"

apm.start({ logger: log, active: true })
global.isKafkaHealthy = true

loanEvents()
log.debug("Connected to Kafka topic: Loan Events")

externalNetsuiteOutbound()
log.debug("Connected to Kafka topic: Ext Netsuite Outbound")

const logDatabase = new LogDatabase()
const server = http.createServer((request, response) => {
  var params = new URLSearchParams(request.url.split("?")[1])

  if (!params.has("apiKey")) {
    const healthcheck = {
      uptime: process.uptime(),
      message: "OK",
      timestamp: Date.now(),
    }
    try {
      response.statusCode = global.isKafkaHealthy ? 200 : 500
      healthcheck.message = global.isKafkaHealthy
        ? "OK"
        : "Issues with kafka consumers"
      response.end(JSON.stringify(healthcheck))
    } catch (error) {
      healthcheck.message = error as string
      response.statusCode = 500
      response.end(JSON.stringify(healthcheck))
    }
  } else {
    if (params.get("apiKey") != constants.logsApiKey) {
      response.statusCode = 403
      response.statusMessage = "FORBIDDEN"
      return response.end()
    }
    if (!params.has("mrId")) {
      response.statusCode = 400
      response.statusMessage = "BAD REQUEST"
      return response.end()
    }
    logDatabase
      .initDatabase()
      .then(client => {
        logDatabase
          .getLogs(params.get("mrId") as unknown as number)
          .then((r) => response.end(JSON.stringify(r.rows)))
      })
  }
})
server.listen(
  constants.port as unknown as number,
  constants.host,
  undefined,
  () => {
    log.debug(`Server is running on http://${constants.host}:${constants.port}`)
  },
)
