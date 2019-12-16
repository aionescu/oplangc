module Opts(Opts(..), getOpts) where

import Options.Applicative

data Opts = Opts {
  optsOptPasses :: Word,
  optsStackSize :: Word,
  optsTapeSize :: Word,
  optsPath :: String
} deriving Show

defaultOptPasses :: Word
defaultOptPasses = 64

defaultStackSize :: Word
defaultStackSize = 65536

defaultTapeSize :: Word
defaultTapeSize = defaultStackSize

optsParser :: ParserInfo Opts
optsParser =
  info
    (helper <*> programOptions)
    (fullDesc <> progDesc "!!!progDesc" <> header "!!!header")

  where
    programOptions :: Parser Opts
    programOptions =
      Opts
        <$> option auto (long "opt-passes" <> metavar "PASSES" <> value defaultOptPasses <> help "The number of optimization passes to perform.")
        <*> option auto (long "stack-size" <> metavar "STACK" <> value defaultStackSize <> help "The size of the stack.")
        <*> option auto (long "tape-size" <> metavar "TAPE" <> value defaultTapeSize <> help "The size of the tape.")
        <*> strArgument (metavar "PATH" <> help "The source file to compile.")

getOpts :: IO Opts
getOpts = execParser optsParser