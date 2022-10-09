
-- | 📦 This module defines constants and functions for working with the NetSuite REST API
module Main (main) where

-- | 📦 importing Prelude module for basic functions
import Prelude

-- | 🔀 importing Control.Monad.Except module for ExceptT monad transformer
-- https://pursuit.purescript.org/packages/purescript-control/4.3.0/docs/Control.Monad.Except
import Control.Monad.Except (ExceptT)

-- | 🔀 importing Control.Monad.Reader module for ReaderT monad transformer
-- https://pursuit.purescript.org/packages/purescript-monad-control/4.0.0/docs/Control.Monad.Reader
import Control.Monad.Reader (ReaderT)

-- | 🔀 importing Control.Monad.Trans.Class module for lift function
-- https://pursuit.purescript.org/packages/purescript-transformers/3.3.0/docs/Control.Monad.Trans.Class#v:lift
import Control.Monad.Trans.Class (lift)

-- | 🔗 importing Data.Function module for & operator
-- https://pursuit.purescript.org/packages/purescript-functions/3.6.0/docs/Data.Function#v:-38-
import Data.Function ((&))

-- | 🔗 importing Data.Maybe module for Maybe type
-- https://pursuit.purescript.org/packages/purescript-maybe/4.4.0/docs/Data.Maybe
import Data.Maybe (Maybe(Just, Nothing))

-- | 🔄 importing Effect module for Effect type
-- https://pursuit.purescript.org/packages/purescript-effects/4.0.0/docs/Effect
import Effect (Effect)

-- | 📦 importing Effect.Uncurried module for uncurry function
-- https://pursuit.purescript.org/packages/purescript-effect-uncurried/1.0.0/docs/Effect.Uncurried#v:uncurry
import Effect.Uncurried (Uncurried)

-- | 🔗 importing Network.HTTP.Simple module for httpLbs function
-- https://hackage.haskell.org/package/http-simple-0.5.3.2/docs/Network-HTTP-Simple.html#v:httpLbs
import Network.HTTP.Simple (Request, httpLbs, parseRequest, setRequestMethod, setRequestQueryString, setRequestBodyJSON)

-- | 🔒 importing Network.OAuth.OAuth1 module for OAuth and def types
-- https://hackage.haskell.org/package/oauth-1.6.1.1/ docs/Network-OAuth-OAuth1.html#t:OAuth
import Network.OAuth.OAuth1 (OAuth(signOAuth), def, newOAuth)

-- | 📦 importing Network.URI.Encode module for decodeText and encodeText functions
-- https://hackage.haskell.org/package/uri-encode-2.0.0/docs/Network-URI-Encode.html#v:decodeText
-- https://hackage.haskell.org/package/uri-encode-2.0.0/docs/Network-URI-Encode.html#v:encodeText
import Network.URI.Encode (decodeText, encodeText)

-- | 📦 importing Network.URI.Types module for URI and URIAuth types
-- https://hackage.haskell.org/package/uri-bytestring-2.1.23/docs/Network-URI-Types-URIByString-ByteString-Internals.html#t:URI
-- https://hackage.haskell.org/package/uri-bytestring-2.1.23/docs/Network-URI-Types-URIByString-ByteString-Internals.html#t:URIAuth
import Network.URI.Types (URI(URI), URIAuth(URIAuth), uriToString)

-- | 🔗 importing Network.Wreq module for Response and responseBody functions
-- https://hackage.haskell.org/package/wreq-1.5.3.0/docs/Network-Wreq.html#t:Response
import Network.Wreq (Response, responseBody)

-- | ⚙️ The oauthKey constant is the key provided by NetSuite
oauthKey :: String
oauthKey = ""

-- | ⚙️ The oauthSecret constant is the secret provided by NetSuite
oauthSecret :: String
oauthSecret = ""

-- | ⚙️ The oauthToken constant is the token provided by NetSuite
oauthToken :: String
oauthToken = ""

-- | ⚙️ The oauthTokenSecret constant is the token secret provided by NetSuite
oauthTokenSecret :: String
oauthTokenSecret = ""

-- | 👾 The oauthRealm constant is the realm provided by NetSuite  
oauthRealm :: String
oauthRealm = ""

-- | 🌐 The baseURL constant is the URL for the NetSuite REST API
baseURL :: String
baseURL =
  process.env.NETSUITE_URL ??
  "https://6768212-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=359&deploy=1"

-- | 🌐 The httpClient constant is a http client created with the baseURL constant
httpClient :: AxiosHttpClient
httpClient =
  axios.create({ baseURL: baseURL, timeout: 60000000 })

-- | 🔐 The addOAuthInterceptor function adds an OAuth authorization header to the httpClient constant
addOAuthInterceptor :: Effect Unit
addOAuthInterceptor =
  let algorithm = "HMAC-SHA256"
      key = oauthKey
      secret = oauthSecret
      token = oauthToken
      tokenSecret = oauthTokenSecret
      realm = oauthRealm
  in
    addOAuthInterceptor(httpClient, { algorithm: algorithm, key: key, secret: secret, token: token, tokenSecret: tokenSecret, realm: realm })

-- | 🏁 The main function exports the httpClient constant
main :: Effect Unit
main =
  export httpClient