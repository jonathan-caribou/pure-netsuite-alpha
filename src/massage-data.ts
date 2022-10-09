import mapping from "./util/wka-mapping"
import lienHolderMapping from "./util/lien-holder-mapping"
import lenderCodeMapping from "./util/lender-code-mapping"
import vendorMapping from "./util/vendor-mapping"
import FundedLoan, {
  Borrower,
  AddressBook,
  LoanOfficer,
  LOS,
} from "./interfaces/funded-loan"
import fetchLienHolderId from "./api/fetch-lien-holder-id"
import log from "./log"

type Datum = {
  [name: string]: number | string
}
type Mapping = {
  [name: symbol]: string
}

type Particle = Borrower | AddressBook | LoanOfficer | LOS
type LienHolder = { id: string; loc_id: string }

function toMMddYYYY(date: Date) {
  const year = date.getFullYear()
  let month = (1 + date.getMonth()).toString()
  month = month.length > 1 ? month : `0${month}`

  let day = date.getDate().toString()
  day = day.length > 1 ? day : `0${day}`

  return `${month}/${day}/${year}`
}

function instantiateConstituent(name: string) {
  switch (name) {
    case "los": {
      return {} as LOS
    }
    case "loan_officer": {
      return {} as LoanOfficer
    }
    case "borrower": {
      return {} as Borrower
    }
    default: {
      return log.error("Bad subgroup name in raw data")
    }
  }
}

export default function massageData(raw_data: string) {
  const q = {} as FundedLoan
  const lienHolder: Datum = {} as Datum
  let gapVendorId: string
  let keys: string[]
  const data: Datum = JSON.parse(raw_data) as Datum
  data.lienholder_name = data.lienholder_name
    .toString()
    .trim()
    .toUpperCase()
    .replace("  ", " ")
  if (!data.lienholder_name || data.lienholder_name === "") {
    data.lienholder_name = "MISSING LIEN HOLDER"
  }

  for (const key of Object.keys(mapping)) {
    keys = (mapping[key] as string).split("/")
    if (!q[keys[0]]) {
      q[keys[0]] = {}
    }
    if (keys.length === 3) {
      if (!(q[keys[0]] as Particle)[keys[1]]) {
        ;(q[keys[0]] as Particle)[keys[1]] = instantiateConstituent(keys[0])
      }
      ;((q[keys[0]] as Particle)[keys[1]] as Particle)[keys[2]] = data[key]
    } else if (data[key]) {
      ;(q[keys[0]] as Particle)[keys[1]] =
        keys[1].slice(-5) === "_date"
          ? toMMddYYYY(
              new Date(
                // Set time to 4AM if there's no time included in timestamp
                // THis fixes issue with date conversion.
                data[key].toString.length === 10
                  ? `${data[key]} 04:00:00`
                  : data[key],
              ) as unknown as Date,
            )
          : data[key]
    }
    q.action = "los"
  }

  // lienHolder = lienHolderMapping[data.lienholder_name] as Datum

  // if (lienHolder) {
  //   q.los.lienHolderId = lienHolder.id.toString()
  //   q.los.lienHolderLocationId = lienHolder.loc_id.toString()
  // }

  q.los.sourceSystem = "Caribou"
  q.los.businessTransactionCategory = "LOAN"
  q.los.businessTransactionType = "REFINANCE"
  q.los.businessTransactionSubType = "REFINANCE"
  q.borrower.addressbook.country = "US"
  q.borrower.isperson = "T"

  if (data.gap_provider) {
    // gapVendorId = fetchVendorId(q.los["transaction_structure_gap_vdr"])
    const value = vendorMapping[data.gap_provider] as number
    q.los.transactionStructureGapVdr = value
  }
  if (data.key_replacement_provider) {
    // var keyReplacementVendorId = fetchVendorId(q.los["transaction_structure_key_replacement_vdr"])
    const value: number = vendorMapping[data.key_replacement_provider] as number
    q.los.transactionStructureKeyReplacementVdr = value
  }
  if (data.cosmetic_package_provider) {
    // var vscVendorId = fetchVendorId(q.los["transaction_structure_vehicle_service_contract_vdr"])
    const value: number = vendorMapping[
      data.cosmetic_package_provider
    ] as number
    q.los.transactionStructureCosmeticCareVdr = value
  }
  if (data.vsc_provider) {
    // var vscVendorId = fetchVendorId(q.los["transaction_structure_vehicle_service_contract_vdr"])
    const value = vendorMapping[data.vsc_provider] as number
    q.los.transactionStructureVehicleServiceContractVdr = value
  }

  return q
}
