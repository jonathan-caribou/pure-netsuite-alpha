import snakecaseKeys from "snakecase-keys"
import camelcaseKeys from "camelcase-keys"
import axiosRetry from "axios-retry"
import { AxiosError, AxiosRequestConfig, AxiosResponse } from "axios"
import httpClient from "./http-client"
import FundedLoan from "../interfaces/funded-loan"
import constants from "../constants"
import sendSlackNotification from "../send-slack-notification"
import sendErrorEmail from "../send-email-notification"
import rollbar from "../rollbar"
import { LoanResponse } from "../interfaces/loan-response"
import log from "../log"
import { LogDatabase } from "../log-database"

let logDatabase = new LogDatabase()

export default async function sendFundedLoan(
  loans:FundedLoan[]
): Promise<void> {
  axiosRetry(httpClient, {
    retries: 4,
    retryDelay: (retryCount) => {
      return axiosRetry.exponentialDelay(retryCount)
    },
    onRetry: (
      retryCount: number,
      error: AxiosError,
      request: AxiosRequestConfig,
    ) => {
      log.error(
        `Failed to load loan to netsuite error: ${error.message} retry count: ${retryCount}. Retrying the loan: ${loans[0].los.sourceSystemId}`,
      )
      log.debug(
        `Loan details for the failed request: ${JSON.stringify(request.data)}`,
      )
    },
  })
  await httpClient
    .post(
      "",
      loans.map((loan: FundedLoan) => snakecaseKeys(loan)),
    )
    .then(async (result: AxiosResponse) => {
      const response = camelcaseKeys(result.data, {
        deep: true,
      }) as unknown as LoanResponse
      log.debug(result)
      if (response.responseCode === 200) {
        log.info(
          `Successfully sent funded loan to Netsuite with MR ID: ${loans[0].los.sourceSystemId}`,
        ) 
        logDatabase
          .initDatabase()
          .then(() =>
            logDatabase.logToDatabase(
              loans[0].los.sourceSystemId as unknown as number,
              JSON.stringify(loans[0]),
              "Sent Successfully",
            ),
          )
      } else {
        await handleFailedLoan(new Error(response.data as string), loans[0])
      }
    })
    .catch(async (error: Error) => {
      // The first request fails
      await handleFailedLoan(error, loans[0])
    })
}

async function handleFailedLoan(error: Error, loan: FundedLoan) {
  const errorMessage = `Failed processing loan [${
    loan.los.sourceSystemId
  }] in NetSuite with error ${error.toString()}`
  log.error(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n>>>>>" +errorMessage)
  rollbar.error(errorMessage)
  await sendErrorEmail(loan, errorMessage)
  await sendSlackNotification(
    errorMessage,
    constants.slackChannelNetsuite as string,
  )
  logDatabase
    .initDatabase()
    .catch((e: any) => "Could not log to PostgreSQL DB:" + console.log(e))
    .then(() =>
      logDatabase.logToDatabase(
        loan.los.sourceSystemId as unknown as number,
        JSON.stringify(loan),
        error.toString(),
      ),
    )
    .catch((e: any) => ":::::LOGS" + console.log(e))
}
