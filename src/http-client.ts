import axios from "axios"
import addOAuthInterceptor from "axios-oauth-1.0a"
import constants from "../constants"

const httpClient = axios.create({
  baseURL:
    process.env.NETSUITE_URL ??
    "https://6768212-sb1.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=359&deploy=1",
  timeout: 60000000,
})

addOAuthInterceptor(httpClient, {
  algorithm: "HMAC-SHA256",
  key: constants.oauthKey,
  secret: constants.oauthSecret,
  token: constants.oauthToken,
  tokenSecret: constants.oauthTokenSecret,
  realm: constants.oauthRealm,
})

export default httpClient
