import constants from "../Constants"

let productionValues = {CAREGARD: 247, VERITAS: 425, ADS: 355}

let values = {CAREGARD: 5472, VERITAS: 5471, ADS: 9088}

export default (if constants.isProduction then productionValues else values)
