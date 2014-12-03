{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Either (rights)
import Control.Monad (replicateM, liftM)
import System.Environment (getArgs)
import System.IO (stdin)
import Data.Attoparsec.Text.Lazy
import Data.Attoparsec.Combinator
import Data.Text.IO (hGetContents, putStr, putStrLn)
import Data.Text (unlines, unwords, pack, Text)
import Prelude hiding (unlines, takeWhile, putStr, putStrLn, unwords)

onf section = do
  xs <- liftM rights . many1' $ eitherP coreference (entry section)
  return $ unlines xs

coreference = do
  many1' $ char '='
  newlines
  skipHeader "Coreference"

data Section
  = Plain
  | Treebank
  | Tree 
  | Leaves

entry Plain = do
  sep
  x <- withHeader "Plain"
  skipHeader "Treebank"
  skipHeader "Tree"
  skipHeader "Leaves"
  return x

entry Treebank = do
  sep
  skipHeader "Plain"
  x <- withHeader "Treebank"
  skipHeader "Tree"
  skipHeader "Leaves"
  return x

entry Tree = do
  sep
  skipHeader "Plain"
  skipHeader "Treebank"
  x <- withHeader "Tree"
  skipHeader "Leaves"
  return x

entry Leaves = do
  sep
  skipHeader "Plain"
  skipHeader "Treebank"
  skipHeader "Tree"
  x <- leaves
  return x

sep = do
  many1' $ char '-'
  newlines

skipHeader h = do
  string h
  restOfLine 
  sep
  value
  newlines
  return ()

withHeader h = do
  string h
  restOfLine 
  sep
  v <- value
  newlines
  return v

value = do
  xs <- many' indented
  newlines
  return $ unwords xs

indented = do
  many1' space
  restOfLine

restOfLine = do
  x <- takeWhile (not . isEndOfLine)
  newlines 
  return x

-- leaves are a special case, since indentation needs to be preserved.
leaves = do
  string "Leaves"
  restOfLine 
  sep
  v <- do
    xs <- many' $ do
      replicateM 4 space
      restOfLine
    newlines
    return $ unlines xs
  newlines
  return v

newlines = many' endOfLine

parseArgs :: [String] -> Either Text Section
parseArgs ["plain"   ] = Right Plain
parseArgs ["treebank"] = Right Treebank
parseArgs ["tree"    ] = Right Tree
parseArgs ["leaves"  ] = Right Leaves
parseArgs _          = Left . unlines $
  [ "Parse an ONF file, returning a given section (one per line)."
  , "Usage:" 
  , "  parse-onf <section>"
  , ""
  , "<section> must be one of [plain, treebank, tree, leaves]"
  , "Input must be piped from standard input."
  ]

main = do
  args <- getArgs
  case parseArgs args of
    Left t -> putStrLn t
    Right section -> do
      input <- hGetContents stdin
      case parseOnly (onf section) input of
        Left s -> error s
        Right t -> putStrLn t
  