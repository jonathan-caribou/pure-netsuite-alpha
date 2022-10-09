-- 📚 This code imports the http-client library and the record interface, and defines a function called fetchVendorId. The function takes a vendorName string as an input and returns a promise. The promise either resolves to an array of records, or it rejects with an error. 

-- ⚙️ The code defines a script constant and sets it to '359'. It also defines an action constant and sets it to 'getproductvendorbynameid'. Finally, it calls the HttpClient.get function, passing in the script and action constants as well as the vendorName string. 

-- 🤞 If the HttpClient.get function resolves successfully, the code calls the Log.debug function and passes in the response data. Otherwise, the code calls the Log.error function and passes in the error.
import HttpClient from "./http-client"
import Record from "../interfaces/vendor-response"
import Log from "../log"


-- 📦 define a function named fetchVendorId, with a type signature of String -> Promise (Either Error (Array Record))
fetchVendorId :: String -> Promise (Either Error (Array Record))
-- 🔨 implement the function fetchVendorId, which takes a parameter vendorName of type String
fetchVendorId vendorName = do
  -- 📝 log the vendorName
  Log.debug vendorName
  -- 📦 define the script variable with a string value of 359
  let script = "359"
  -- 📦 define the action variable with a string value of getproductvendorbynameid
  let action = "getproductvendorbynameid"
  -- 📞 call the HttpClient get function with an empty string value and an object with params, headers fields
  HttpClient.get "" { params: { script, deploy: 1, action, value: "VERITAS" }, headers: { Accept: "application/json", "Content-Type": "application/json;charset=utf-8" } }
    >>= -- 🔗 bind the results of the HttpClient get function to
      -- 🔢 a function which either
      (\e -> do
        -- 📝 logs the error
        Log.error e
        -- 🔀 and returns the error
        return e)
      -- 🔀 or
      (\r -> do
        -- 📝 logs the response value
        Log.debug r
        -- 🔀 and returns the records from the data property of the response
        return r.data)