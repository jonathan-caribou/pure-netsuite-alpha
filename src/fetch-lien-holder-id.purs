-- ➡️ First, this code creates a log with the lien holder name. 
-- 📝 Next, it defines the script and action. 
-- 🌐 Then, it uses the httpClient to get the appropriate params and headers. 
-- ✅ Finally, it uses the ExceptT monad to either return a value or an error. 

-- ⚠️ If there is an error, it will show the error. 
-- If there is not an error, it will return the id and the loc_id.

-- This code allows you to fetch the lien holder id for a given lien holder name. 
-- The code defines a function, fetchLienHolderId, that takes a lien holder name and returns the lien holder's id. 

In order to fetch the lien holder id, the code firstly logs the lien holder name. It then defines the script and action. Next, the code uses the httpClient function to make a GET request. This request is made up of the params and headers defined earlier in the script. The code uses the ExceptT monad to either return a value or an error. If there is an error, it will show the error. If there is not an error, it will return the id and the loc_id.
import Prelude
import Control.Monad.Trans.Except
import Control.Applicative ((<$>), (<*>))
import Data.Functor (($>))
import qualified Effect as E
import Effect.Unlift ( MonadIO(..) )
import Control.Monad ((>>=), liftM2, join, return)
import HttpClient (httpClient)

-- | Fetch the lien holder id for a given lien holder name
fetchLienHolderId :: forall m a . (MonadIO m) => String -> ExceptT String m a
fetchLienHolderId lienHolderName = do
  -- Log the lien holder name
  log.debug(lienHolderName)

  -- Define the script and action
  let script = "359"
  let action = "getlienholderbynameid"

  -- ExceptT allows us to lift this entire http request into our monad stack
  ExceptT $
    -- Hit the httpClient with the appropriate params and headers
    httpClient.get("", {
      params: {script, deploy: 1, action, value: lienHolderName},
      headers: {"Accept": "application/json", "Content-Type": "application/json;charset=utf-8"}
    } >>= \response ->
      
      -- ExceptT allows us to either return a value or an error
      ExceptT . return $ response.data >>= \responseData -> case (responseData :: Datum) of
        Left err -> Left $ show err

        -- pattern match on a list with at least one element
        Right ((data'' :: [Datum]) -> (_ :: Datum):_) -> Right {id: asString(_.internal_netsuite_id), loc_id: asString(_.address[0].addrid)}

  where
    -- A helper function to convert something to a string
    asString :: forall b. Show b => (Datum -> b) -> String
    asString f = show $ f (datum__ :: Datum)

    -- This is just a placeholder value so that the types will work
    datum__ :: Datum
    datum__ = undefined
    -- log = E.log
    -- debug = E.debug
