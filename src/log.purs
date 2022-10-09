module Main where

import Prelude
import Control.Monad.IO.Class
import Effect (Effect)
import Node.Pino (LoggerOptions, pino, logLevel)
import Node.Pino.Ecs (ecsFormat)

loggerOptions :: LoggerOptions
loggerOptions = ecsFormat
  { logLevel = Debug
  }

main :: Effect Unit
main = do
  pino loggerOptions
  pure unit