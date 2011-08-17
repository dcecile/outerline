{-# LANGUAGE ExistentialQuantification, Rank2Types #-}

module Synops where

import Control.Applicative

data MaybeS x =
  NothingS
  | JustS !x

maybeS d _ (NothingS) = d
maybeS _ f (JustS x) = f x

data Extent = Extent Int Int
  deriving (Show, Eq)

data Stream c = Stream [c] Int

data Parser c x = Parser (forall y. (Stream c -> x -> MaybeS y) -> Stream c -> MaybeS y)

instance Functor (Parser c) where
  f `fmap` Parser p = Parser $ \s i ->
    p (\i' -> s i' . f) i

instance Applicative (Parser c) where
  pure x = Parser $ \s i -> s i x
  Parser f <*> ~(Parser x) = Parser $ \s i ->
    f (\i' f' -> x (\i'' x' -> s i'' $! f' x') i') i

instance Alternative (Parser c) where
  empty = Parser $ \_ _ -> NothingS
  Parser a <|> Parser b = Parser $ \s i ->
    maybeS (b s i) JustS (a s i)

parseList :: Parser c x -> [c] -> Maybe x
parseList (Parser p) c = maybeS Nothing Just $ p f (Stream c 0)
  where
  f (Stream [] _) x = JustS x
  f _ _ = NothingS

examples = mapM_ putStrLn
  [ f ( pure 'b' <|> token 'a'
    , "")
  , f ( pure 'b' <|> token 'a'
    , "a")
  , f ( pure (1 :: Integer) <|> (* 2) <$> (token 'a' *> pure 4)
    , "a")
  , f ( pure (1 :: Integer) <|> (* 2) <$> (token 'a' *> pure 4)
    , "b")
  , f ( pure (1 :: Integer) <|> (* 2) <$> (token 'a' *> pure 4)
    , "")
  , f ( many (token 'a')
    , "aaaaaaa")
  , f ( (token 'a' *> token 'a' *> token 'a' *> pure 3) <|>
          (token 'a' *> token 'a' *> pure 2)
    , "aaa")
  , f ( (token 'a' *> token 'a' *> token 'a' *> pure 3) <|>
          (token 'a' *> token 'a' *> pure 2)
    , "aa")
  , f ( liftA2 (,) (pure 'a' <|> token 'b') (token 'c')
    , "bc")
  , f ( liftA2 (,) (pure 'a' <|> token 'b') (token 'c')
    , "c")
  , f ( liftA2 (,) (many $ token 'b') (token 'c')
    , "c")
  , f ( liftA2 (,) (many $ token 'b') (token 'c')
    , "bbbbc")
  , f ( (,,,,) <$> currentPosition <*> (many $ token 'b') <*> currentPosition <*> (token 'c')
               <*> currentPosition
    , "bbbbc")
  , f ( (many $ token 'a') *> (extent $ (,) <$> (many $ token 'b')) <* (many $ token 'c')
    , "aabbbbc")
  ]
  where
  f (p, d) = show $ parseList p d

match t = Parser $ \s i -> case i of
  (Stream (x:xs) n) | t x -> s (Stream xs (n + 1)) x
  _ -> NothingS
token t = match ({-# SCC "testing" #-} (== t))

notToken t = match (/= t)

text [] = pure ()
text (x:xs) = token x *> text xs

currentPosition :: Parser c Int
currentPosition = Parser $ \s i@(Stream _ n) -> s i n

extent :: Parser c (Extent -> x) -> Parser c x
extent p = (\b f e -> f (Extent b e)) <$> currentPosition <*> p <*> currentPosition

sepBy s x = (liftA2 (:) x (many (s *> x))) <|> pure []
