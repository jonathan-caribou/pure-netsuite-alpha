/* -------------------------------------------------------------------------- */
// Loan input
export default interface FundedLoan {
  action: string
  los: LOS
  borrower: Borrower
  loanOfficer: LoanOfficer
}
/* -------------------------------------------------------------------------- */

export interface Borrower {
  internalNetsuiteId: number
  addressbook: AddressBook
  category: string
  email: string
  firstname: string
  isperson: string
  companyname: string
  lastname: string
  phone: string
  receivablesaccount: string
  subsidiary: string
}

export interface AddressBook {
  addr1: string
  addr2: string
  city: string
  state: string
  country: string
  zip: string
}

export interface LoanOfficer {
  employeeSalesAgentFirstname: string
  employeeSalesAgentLastname: string
  employeeSalesAgentEmailaddress: string
  email: string
  internalNetsuiteId: number
  externalid: string
  firstname: string
  issalesrep: boolean
  lastname: string
  subsidiary: string
}

export interface LOS {
  sourceSystem: string
  sourceSystemId: string
  businessTransactionCategory: string
  businessTransactionType: string
  businessTransactionSubType: string
  leadSource: string
  lenderUniqueCode: string
  lenderId: null
  lenderLoanId: string
  lienHolderId: string
  lienHolderLocationId: string
  lienHolderLocationAcctNum: string
  lienHolderPerDiem: number
  lienHolderPayoffGoodUntilDate: string
  ficoNo: string
  coversheetFinalizationDate: string
  fundingDate: string
  transactionStructureLenderSurchargePrice: number
  transactionStructureShortFundPrice: number
  transactionStructureOverFundPrice: number
  transactionStructureLoanPayoffAmount: number
  transactionStructureProcessingPrice: number
  transactionStructureSalesTax: number
  transactionStructureOtherFee: number
  transactionStructureAxosAap: number
  transactionStructureLicenseFeeAmt: number
  transactionStructureOriginationPct: number
  transactionStructureOriginationPrice: number
  transactionStructureGapCost: number
  transactionStructureGapPrice: number
  transactionStructureGapTerm: string
  transactionStructureGapType: string
  transactionStructureGapNo: string
  transactionStructureGapVdr: number
  transactionStructureKeyReplacementPrice: number
  transactionStructureKeyReplacementCost: number
  transactionStructureKeyReplacementNo: string
  transactionStructureKeyReplacementVdr: number
  transactionStructureCosmeticCarePrice: number
  transactionStructureCosmeticCareCost: number
  transactionStructureCosmeticCareNo: string
  transactionStructureCosmeticCareVdr: number
  transactionStructureVehicleServiceContractPrice: number
  transactionStructureVehicleServiceContractCost: number
  transactionStructureVehicleServiceContractTerm: string
  transactionStructureVehicleServiceContractType: string
  transactionStructureVehicleServiceContractNo: string
  transactionStructureVehicleServiceContractVdr: number
  transactionStructureDmvPrice: number
  totalAmountFinanced: number
  vehicleVin: string
  internalNetsuiteId: number
}
