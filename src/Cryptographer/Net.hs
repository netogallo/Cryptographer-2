{-# Language JavaScriptFFI, OverloadedStrings, FlexibleContexts #-}
module Cryptographer.Net (
    getAsync,
    NetworkException
) where
    
 import Control.Concurrent.Async
 import Control.Applicative ((<$>), (<*>))
 import Control.Concurrent.MVar
 import Control.Monad.Exception
 import Control.Monad.IO.Class (liftIO)
 import Data.Either
 import Data.Text (Text)
 import Data.Typeable
 import qualified Data.Text as T
 import qualified Data.Map as M
 import GHCJS.Foreign.Callback (Callback, syncCallback1, OnBlocked(ContinueAsync))
 import qualified Data.JSString as JSS
 import GHCJS.Marshal(fromJSVal)
 import GHCJS.Types (JSVal, nullRef)
 
 foreign import javascript unsafe "JSGetAsync($1,{},$2,$3)" doNet :: JSS.JSString -> Callback a -> Callback a -> IO ()
 
 data NetworkException = 
     NetworkException
    | InvalidContent deriving (Show, Typeable)
 
 instance Exception NetworkException
 
 pack = JSS.pack . T.unpack
 unpack = T.pack . JSS.unpack 
 
 getAsync :: Throws NetworkException l => Text -> M.Map Text Text -> IO (Async (EMT l IO Text))
 getAsync url args = do
     putStrLn "getAsync"
     res <- newEmptyMVar
     let callback result = putMVar res (Right result)
         errorFn err = putMVar res (Left err)
     f1 <- syncCallback1 ContinueAsync callback
     f2 <- syncCallback1 ContinueAsync errorFn
     doNet (pack url) f1 f2
     async $ do
         liftIO $ putStrLn "mvar"
         val <- takeMVar res
         liftIO $ putStrLn "mvar2"
         return $ case val of
             Left _ -> throw NetworkException
             Right val' -> do
                 content <- liftIO $ fromJSVal val'
                 case content of
                    Nothing -> throw InvalidContent
                    Just val'' -> return . unpack $ val'' 
         
 