export default interface Response {
  responseCode: number
  message: string
  data: [Record]
}
export interface Record {
  firstname: string
  lastname: string
  companyname: string
  inactive: boolean | null
  email: string
  phone: string
  internal_netsuite_id: string
  address: [Address]
}
export interface Address {
  addrid: string
  addr1: string
  addr2: string
  city: string
  state: string
  country: string
  zip: string
  inactive: boolean | null
}
