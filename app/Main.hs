{-# Language OverloadedStrings, ScopedTypeVariables #-}
module Main where

import Control.Concurrent.Async
import Control.Monad.IO.Class (liftIO)
import Control.Monad.Exception
import Reflex
import Reflex.Dom
import Data.Text.IO as T

import Cryptographer.Net
import Lib
import UI.Context

main :: IO ()
main = do
    T.putStrLn "hei"
    req <- getAsync "http://google.com" undefined
    req' <- wait $ req
    
        -- async (gg >>= liftIO . T.putStrLn)
    v <- runEMT (req' `catchWithSrcLoc` (\_ (_ :: NetworkException) -> return "bad"))
    -- T.putStrLn v
    
    mainWidget $ el "div" $ do
        text "Hola"
        _ <- textInput def{ _textInputConfig_inputType = "password" }
        return ()