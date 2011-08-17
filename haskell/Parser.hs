{-# LANGUAGE NoMonomorphismRestriction #-}

import Control.Applicative
import Data.Char
import Data.List
import Data.Map (Map)
import qualified Data.Map as Map
import Data.Maybe
import Data.Function
import Control.Monad.RWS

import Synops

data Expression
  = Text
    String
  | Call
    [Argument]
  deriving Show

data Argument
  = Argument
    Bool
    Expression
  deriving Show

argumentExpression (Argument _ e) = e

anyToken = match $ const True

comment =
  text "#"
  *> many (match (/= '\n'))
  *> pure ()

space0 =
  many
    (comment
    <|> match isSpace *> pure ())
  *> pure ()

stringChar =
  (match (== '`') *> anyToken)
  <|> anyToken

textArgument =
  (space0 *> pure "")
  <|> ((:)
    <$> stringChar
    <*> textArgument)

callArgument =
    text "("
    *> allArguments
    <* text ")" <* space0

oneArgument = Argument
  <$>
    (text "@" *> space0 *> pure True
    <|> pure False)
  <*>
    (Call <$> callArgument
    <|> Text <$> textArgument)

allArguments =
  sepBy (text ",")
    (space0 *> oneArgument)

parse = parseList allArguments

frequencies (Text t) =
  Map.insertWith (+) t 1
frequencies (Call a) =
  flip (foldr frequencies) (map argumentExpression a)

huffmanCoding =
  Map.fromList
  . (`zip` [0..])
  . fst . unzip
  . sortBy (flip compare `on` snd)
  . Map.toList

callList (Text t) = do
  (Map.! t) <$> ask
callList (Call a) = do
  r <- mapM callList . map argumentExpression $ a
  modify (+ 1)
  n <- get
  tell [(n, r)]
  return n

compile s = let
  (Just a) = parse s
  e = Call (Argument False (Text "main") : a)
  f = frequencies e Map.empty
  h = huffmanCoding f
  c = snd $ evalRWS (callList e) h (Map.size h - 1)
  h' = map (\p -> show (snd p) ++ " " ++ fst p) . Map.toList $ h
  c' = map (intercalate " " . map show . uncurry (:)) c
  in
  intercalate "\n" $ h' ++ [""] ++ c' ++ [""]

main =
  interact compile
