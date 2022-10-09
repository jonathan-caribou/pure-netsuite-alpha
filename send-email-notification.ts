import MailService from "@sendgrid/mail"
import constants from "./constants"
import FundedLoan from "./interfaces/funded-loan"
import log from "./log"

MailService.setApiKey(constants.sendgridApiKey)

export default async function sendErrorEmail(
  loan: FundedLoan,
  errorMessage: string,
) {
  await MailService.send(emailAttributes(loan, errorMessage))
    .then((response) => {
      log.debug(`${response[0].statusCode}`)
      log.debug(`Successfully sent email`)
    })
    .catch((error) => {
      log.error(error)
    })
}

function emailAttributes(loan: FundedLoan, error: string) {
  log.debug(constants.emailRecipients)
  const attribute = {
    subject: `MR ${loan.los.sourceSystemId} Loan Failed Funding in NS`,
    text: error,
    to: constants.emailRecipients.split(","),
    from: "Caribou <notifications@gocaribou.com>",
  }
  return attribute
}
