{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses #-}

module Parser(Parser.parse) where

import Control.Exception(assert)

import Data.HashMap.Strict(HashMap)
import qualified Data.HashMap.Strict as HashMap

import Data.Text(Text)

import Text.Parsec
import Text.Parsec.Char

import Ast

type Parser = Parsec Text ()

skip :: Parser a -> Parser ()
skip p = do
  p
  pure ()

comment :: Parser ()
comment = do
  char '#'
  manyTill anyChar (skip endOfLine <|> eof)
  pure ()

justWs :: Parser ()
justWs = skipMany (skip space <|> comment)

ws :: Parser a -> Parser a
ws p = do
  r <- p
  justWs  
  pure r

intrinsics :: String
intrinsics = "+-<>,.;:"

reserved :: String
reserved = intrinsics ++ "[]{}# \t\r\n"

intrinsic :: Parser Op
intrinsic = choice [incr', decr', movl', movr', read', write, pop', push]
  where
    incr' = incr <$ char '+'
    decr' = decr <$ char '-'
    movl' = movl <$ char '<'
    movr' = movr <$ char '>'
    read' = Read <$ char ','
    write = Write <$ char '.'
    pop' = pop <$ char ';'
    push = Push <$ char ':'

loop :: Parser Op
loop = Loop <$> between (ws $ char '[') (char ']') (many $ ws op)

custom :: Parser Char
custom = noneOf reserved

op :: Parser Op
op = choice [intrinsic, loop, (OpCall . Just) <$> custom]

opDef :: Parser Def
opDef = do
  name <- ws custom
  ws $ char '{'
  body <- many $ ws op
  char '}'
  pure $ (Just name, body)

program :: Parser Dict
program = do
  justWs
  defs <- many $ try $ ws opDef
  topBody <- many $ ws op
  let topLevel = (Nothing, topBody)
  eof
  pure $ HashMap.fromList (topLevel : defs)

parse :: Text -> Either String Dict
parse input =
  case runParser program () "" input of
    Left err -> Left $ show err
    Right p -> Right p