import camelcaseKeys from "camelcase-keys"
import fs from "node:fs/promises"
import path from "node:path"
import log from "./log"
import sendFundedLoan from "./api/send-funded-loan"
import fetchVendorId from "./api/fetch-vendor-id"
import massageData from "./massage-data"
import FundedLoan from "./interfaces/funded-loan"
import rawData from "./util/data4"
import fails from "./util/111"
import fetchLienHolderId from "./api/fetch-lien-holder-id"

const fileToLoad = process.argv.slice(2)[0]
const fData: object[] = []
type Datum = {
  [name: string]: number | string
}
export default async function run() {
  try {
    for (const d of rawData) {
      if (fails.includes(d.loan_application_id)) {
        fData.push(d)
      }
    }

    // eslint-disable-next-line unicorn/prefer-module
    // const fails = require("./util/111.json")
    // for (let index = 0; index < rawData.length; index += 1) {
    //   // log.info(index)
    //   //if (rawData[index].loan_application_id == 2046805){
    //   const lienHolder = await fetchLienHolderId(
    //     JSON.parse(JSON.stringify(rawData[index])).lienholder_name as string,
    //   )
    const loan = camelcaseKeys(massageData(JSON.stringify(rawData[0])), {
      deep: true,
    }) as unknown as FundedLoan
    //   if (lienHolder) {
    //     loan.los.lienHolderId = lienHolder.id as string
    //     loan.los.lienHolderLocationId = lienHolder.loc_id as string
    //   }
    //   // log.info(loan)
    const result = await sendFundedLoan([loan])
    //   // loans = []
    //   // log.info(loan)
    // }
    // }
  } catch (error) {
    log.error(error)
  }
}

run().catch((error) => log.error(error))
