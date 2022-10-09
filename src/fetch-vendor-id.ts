import httpClient from "./http-client"
import { Record } from "../interfaces/vendor-resonse"
import log from "../log"

export default async function fetchVendorId<T>(
  vendorName: string,
): Promise<any> {
  log.debug(vendorName)
  const script = "359"
  const action = "getproductvendorbynameid"
  try {
    const response = await httpClient.get("", {
      params: {
        script,
        deploy: 1,
        action,
        value: "VERITAS",
      },
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json;charset=utf-8",
      },
    })
    // log.info(JSON.stringify(response.data, null, 4))
    // log.info("response status is: ", response.status)
    log.debug(response)
    return response.data as Array<Record>
  } catch (error) {
    log.error(error)
    return error as string
    // if (httpClient.isAxiosError(error)) {
    //   log.info("error message: ", error.message)
    //   return error.message
    // } else {
    //   log.info("unexpected error: ", error)
    //   return "An unexpected error occurred"
    // }
  }
}
