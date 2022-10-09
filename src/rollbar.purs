
module Rollbar
  (
  )
  where

import Prelude

import Rollbar (Rollbar, accessToken, captureUncaught, captureUnhandledRejections, error, new)

import Constants (rollbarToken)


rollbar = new { accessToken: rollbarToken, captureUncaught: true, captureUnhandledRejections: true }
