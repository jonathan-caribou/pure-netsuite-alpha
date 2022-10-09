import Data.Mapping
import Data.Maybe (Maybe(..))
import LienHolderMapping
import LenderCodeMapping
import VendorMapping
import Record
import Effect (Effect)
import Date (toMMddYYYY)
import FetchLienHolderId (fetchLienHolderId)
import Log (log)

type Datum = { [ name :: String ] :: Number | String }
type Mapping = { [ name :: Symbol ] :: String }

type Particle = Borrower | AddressBook | LoanOfficer | LOS
type LienHolder = { id :: String, loc_id :: String }

-- | This function converts a date into a string in the format MM/DD/YYYY.
toMMddYYYY :: Date -> String
toMMddYYYY date =
  let year = date.getFullYear()
      month = (1 + date.getMonth()).toString()
      month = month.length > 1 ? month : "0" <> month

      day = date.getDate().toString()
      day = day.length > 1 ? day : "0" <> day

  in month <> "/" <> day <> "/" <> year

-- | This function creates an empty object for each subgroup in the data.
instantiateConstituent :: String -> Effect Unit Particle
instantiateConstituent name = case name of
  "los" -> pure {}
  "loan_officer" -> pure {}
  "borrower" -> pure {}
  _ -> log.error "Bad subgroup name in raw data"
  
-- | This function takes in the raw data as a string, parses it into JSON, and then loops through each key in the data to create a new object with the correct data in the correct subgroup.  
massageData :: String -> Effect Unit FundedLoan
massageData raw_data = do
  let q = {} :: FundedLoan -- create an empty object to store the data in the correct format
      lienHolder :: Datum = {} :: Datum -- create an empty object to store the lienholder data

  let gapVendorId :: Maybe String <- Nothing -- create an empty variable to store the gap vendor ID 
      keys :: [String] <- [] -- create an empty array to store the keys from the data 
      data :: Datum <- JSON.parse(raw_data) -- parse the raw data into JSON

  data.lienholder_name <- data.lienholder_name.toString().trim().toUpperCase().replace("  ", " ") -- clean up the lienholder name so that it is in all uppercase letters with no extra spaces

  if !data.lienholder_name || data.lienholder_name == "" then do -- if there is no lienholder name included in the data...
    data.lienholder_name <- "MISSING LIEN HOLDER" -- set the lienholder name to "MISSING LIEN HOLDER"

  for key of Object.keys(mapping) do do -- loop through each key in the mapping object...
    keys <- (mapping[key] as string).split("/") -- split the key into subgroups

    if !q[keys[0]] then do -- if there is no object for this subgroup yet...
      q[keys[0]] <- {} -- create an empty object for this subgroup

    if keys.length == 3 then do -- if this key has three subgroups...
      if !(q[keys[0]] as Particle)[keys[1]] then do -- if there is no object for this subgroup yet...
        (q[keys[0]] as Particle)[keys[1]] <- instantiateConstituent(keys[0]) -- create an empty object for this subgroup

      ((q[keys[0]] as Particle)[keys[1]] as Particle)[keys[2]] <- data[key] -- add the data to this subgroup

    else if data[key] then do -- otherwise, if there is data for this key...  
-- | Set time to 4AM if there's no time included in timestamp to fix date conversion issue.     (q[keys[0]] as Particle)[keys[1]] <- if keys[1].slice(-5) == "_date" then toMMddYYYY(new Date(  data[key].toString.length == 10 ? `${data[key]} 04:00:00` : data[key] ) as unknown as Date) else data[key] -- convert the timestamp into the correct format

  q.action <- "los"

  q.los.sourceSystem <- "Caribou" -- set the source system to "Caribou"
  q.los.businessTransactionCategory <- "LOAN" -- set the business transaction category to "LOAN"  
  q.los.businessTransactionType <- "REFINANCE" -- set the business transaction type to "REFINANCE"  
  q.los.businessTransactionSubType <- "REFINANCE" -- set the business transaction subtype to "REFINANCE"  

  q.borrower.addressbook.country <- "US" -- set the country to "US"

  q.borrower.isperson <- "T" -- set borrower type to person

  if data.gap_provider then do -- if there is a gap provider included in the data...  
    let value <- vendorMapping[data.gap_provider] as number -- look up the gap provider in the vendor mapping object

    q.los.transactionStructureGapVdr <- value -- set the gap provider in the outputted data

  if data.key_replacement_provider then do -- if there is a key replacement provider included in the data...  
    let value <- vendorMapping[data.key_replacement_provider] as number -- look up the key replacement provider in the vendor mapping object

    q.los.transactionStructureKeyReplacementVdr <- value -- set the key replacement provider in the outputted data

  if data.cosmetic_package_provider then do -- if there is a cosmetic package provider included in the data...  
    let value <- vendorMapping[data.cosmetic_package_provider] as number -- look up the cosmetic package provider in the vendor mapping object

    q.los.transactionStructureCosmeticCareVdr <- value -- set the cosmetic package provider in the outputted data

  if data.vsc_provider then do -- if there is a VSC provider included in the data...  
    let value <- vendorMapping[data.vsc_provider] as number -- look up the VSC provider in the vendor mapping object

    q.los.transactionStructureVehicleServiceContractVdr <- value -- set the VSC provider in the outputted data

  pure q