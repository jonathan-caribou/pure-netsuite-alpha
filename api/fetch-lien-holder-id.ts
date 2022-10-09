// ⚙️ This code is used to fetch the lien holder ID. 
// 📦 First, the code imports the httpClient, Record, and log files. 
// ✨ Next, the code creates a new data type called Datum. This data type can be a number, string, or object. 
// 💻 The code then creates an async function called fetchLienHolderId that takes in a string called lienHolderName. This function will return 🔮 of type object. 
// 🔀 The code then sets the script and action variables. The script variable is set to "359" and the action variable is set to "getlienholderbynameid". 
// 🌐 The code then makes a GET request to the HTTP client using the script, action, and lienHolderName variables as input parameters . 
// ✅ The ID and location are returned if successful . If there's an error, ⚠️️the error will be logged & returned as an object .

import httpClient from "./http-client"  // 🔁 This is importing the HTTP client
import { Record } from "../interfaces/vendor-resonse"  // 📋 This is importing the Record interface from the vendor-response file
import log from "../log"  // 📝 This is importing the log file

type Datum = {  // 📦 This is creating a new data type called Datum
  [name: string]: number | string | object  // 📝 This indicates that a Datum can be a number, string, or object
}

export default async function fetchLienHolderId<T>(  // ☁️ This is the async function that will be run to fetch the lien holder ID
  lienHolderName: string,  // 📋 This is the string that will be passed into the function
): Promise<object> {  // 🏁 This function will return a promise of type object
  log.debug(lienHolderName)  // 🔎 This will log the lien holder name that was passed into the function
  const script = "359"  // 🔢 This is the script that will be run
  const action = "getlienholderbynameid"  // 🔗 This is the action that will be taken
  try {
    const response = await httpClient.get("", {  // 🌐 This will make a GET request to the HTTP client
      params: {
        script,  // 🔚 This is the script that will be run
        deploy: 1,  // 🚀 This is the deployment
        action,  // 🔁 This is the action that will be taken
        value: lienHolderName,  // 📮 This is the value that will be passed in
      },
      headers: {  // 🗂 These are the headers that will be used
        Accept: "application/json",  // This header says that the response will be in JSON format
        "Content-Type": "application/json;charset=utf-8",  // This header says that the content type will be JSON
      },
    })
    return {
      id: ((response.data as Datum).data[0] as Datum)  // This will return the ID
        .internal_netsuite_id as string,
      loc_id: (((response.data as Datum).data[0] as Datum).address[0] as Datum)  // This will return the location ID
        .addrid as string,
    } as Datum  // 📬 This will return the Datum
  } catch (error) {  // 🍀 This will catch any errors that occur
    log.error(error)  // 🚨 This will log the error
    return error as object  // 🚨 This will return the error as an object
    // if (httpClient.isAxiosError(error)) {  // This will check to see if the error is an Axios error
    //   log.info("error message: ", error.message)  // This will log the error message
    //   return error.message  // This will return the error message
    // } else {  // This will run if the error is not an Axios error
    //   log.info("unexpected error: ", error)  // This will log the unexpected error
    //   return "An unexpected error occurred"  // This will return the string "An unexpected error occurred"
    // }
  }
}