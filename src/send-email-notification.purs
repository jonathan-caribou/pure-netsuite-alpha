module SendErrorEmail where

import Effect.Uncurried (Uncurried)

import MailService from "@sendgrid/mail"
import constants from "./constants"
import FundedLoan from "./interfaces/funded-loan"
import log from "./log"

setApiKey :: forall effect. Uncurried Effect Unit -> Effect Unit
setApiKey = MailService.setApiKey <<< constants.sendgridApiKey

sendErrorEmail :: forall effect. Uncurried Effect Unit -> Effect Unit
sendErrorEmail loan = do
  log.debug <<< constants.emailRecipients
  MailService.send <<< emailAttributes loan
  where
  emailAttributes :: FundedLoan -> String -> String
  emailAttributes loan errorMessage = {
    subject: `MR ${loan.los.sourceSystemId} Loan Failed Funding in NS`,
    text: errorMessage,
    to: constants.emailRecipients.split(","),
    from: "Caribou <notifications@gocaribou.com>",
  }