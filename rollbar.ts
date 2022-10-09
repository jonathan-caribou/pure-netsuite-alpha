import Rollbar from "rollbar"
import constants from "./constants"

const rollbar = new Rollbar({
  accessToken: constants.rollbarToken,
  captureUncaught: true,
  captureUnhandledRejections: true,
})

export default rollbar
