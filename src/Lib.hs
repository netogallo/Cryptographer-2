{-# LANGUAGE JavaScriptFFI, EmptyDataDecls #-}

module Lib
    ( fun
    ) where

foreign import javascript unsafe "func();" fun :: IO ()

