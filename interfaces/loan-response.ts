import FundedLoan from "./funded-loan"

/* -------------------------------------------------------------------------- */
// Loan response
export interface LoanResponse {
  responseCode: number
  message: string
  data: FundedLoan[] | string
}
