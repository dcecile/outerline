data Expression
  = Text
  { text :: String
  }
  | Call
  { operator :: Expression
  , arguments :: [Expression]
  }
  deriving Show

data Argument
  = Argument
  { key :: Bool
  , argument :: Expression
  }
  deriving Show

compile (Text t) = lazyValue . (:[]) . StringValue $ t
compile (Call o a) = Lambda $ \e [] -> let
  Lambda l = apply
  in
  l e (map (LazyArgument . compile) $ o : a)

test = run . chain . map compile

chain (Lambda l : []) = Lambda $ \e [] -> let
  (e', v) = l e []
  in
  (e', v)
chain (Lambda l : ls) = Lambda $ \e [] -> let
  (e', _) = l e []
  Lambda l' = chain ls
  in
  l' e' []

data Value
  = StringValue String
  | LambdaValue Lambda

instance Show Value where
  show (StringValue s) = show s
  show (LambdaValue _) = "lambda"

data LazyArgument
  = LazyArgument
  { lazyArgument :: Lambda
  }

data Environment
  = Environment [(String, Lambda)]

data Lambda
  = Lambda (Environment -> [LazyArgument] -> (Environment, [Value]))

lazyValue v = Lambda $ \e [] -> (e, v)

eval _ [] = []
eval e ((LazyArgument (Lambda a)):as) =
  v ++ eval e' as
  where
  (e', v) = a e []

envPut (Environment e) n v = Environment $ (n, v) : e  

envGet (Environment e) n = snd . head . filter (\(n', v) -> n == n) $ e  

var = Lambda $ \e a -> let
  ((StringValue name):value) = eval e a
  in
  ( envPut e name (lazyValue value)
  , value)

run (Lambda l) =
  v
  where
  (e, v) = l (Environment [("var", var)]) []

apply = Lambda $ \e (a:as) -> let
  [StringValue n] = eval e [a]
  Lambda l = envGet e n
  in
  l e as

t1 = test [Call (Text "var") [Text "x", Text "y"], Text "z", Call (Text "x") []]
