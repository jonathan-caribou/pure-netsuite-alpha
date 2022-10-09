import constants from "../constants"

const productionValues = {
  CAREGARD: 247,
  VERITAS: 425,
  ADS: 355,
}

const values = {
  CAREGARD: 5472,
  VERITAS: 5471,
  ADS: 9088,
}

export default constants.isProduction ? productionValues : values
