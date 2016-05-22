module UI.Context where

import Control.Applicative
import Control.Monad
import Data.Functor
import Data.Text    
import Reflex
import Reflex.Dom
import Reflex.Dom.Internal
import Reflex.Host.Class

-- | Data structure that contains the information necessary to
-- recover and decrypt an encrypted data source
data DataContext = DataContext {
    key :: Text,
    resource :: Text
}

newtype CryptographerM a = CryptographerM { runCryptographer :: DataContext -> Widget Spider (Gui Spider (WithWebView SpiderHost) (HostFrame Spider)) a }

instance Functor CryptographerM where
    fmap f a = CryptographerM $ \ctx -> do
        v <- runCryptographer a ctx
        return $ f v

instance Applicative CryptographerM where
    f <*> a = CryptographerM $ \ctx -> do
        v <- runCryptographer a ctx
        runCryptographer (f <*> pure v) ctx
    
    pure a = CryptographerM $ \_ -> return a

