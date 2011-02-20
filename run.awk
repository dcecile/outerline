BEGIN {
  died = false()
  readingStrings = true()
  "" in symbols
  main = ""

  totalListSize = 0
  "" in totalList
  totalStringSize = 0
  "" in totalString
  totalStructSize = 0
  "" in totalStruct
  totalLambdaSize = 0
  "" in totalLambda

  globalStrings()
}

function true() {
  return 1
}
function false() {
  return 0
}

function die(message) {
  print message > "/dev/stderr"
  close("/dev/stderr")
  exit 1
  died = true()
}
function assert(condition, message) {
  if (!condition) {
    die(message)
  }
}

function globalStrings() {
  keyString = stringNew("key")
  typeString = stringNew("type")
  exprString = stringNew("expr")
  stringStringList = stringListNew(stringNew("string"))
  callStringList = stringListNew(stringNew("call"))
}

function listNew(spec,  i) {
  totalListSize++
  totalList[totalListSize, "size"] = spec["size"]
  for (i = 1; i <= spec["size"]; i++) {
    totalList[totalListSize, i, "type"] = spec[i, "type"]
    totalList[totalListSize, i, "id"] = spec[i, "id"]
  }
  return totalListSize
}
function listNew1(type, value,  listSpec) {
  listSpec["size"] = 1
  listSpec[1, "type"] = type
  listSpec[1, "id"] = value
  return listNew(listSpec)
}
function listGet(id, i, type) {
  assert((id, "size") in totalList, "Bad list id: " id ", " i ", " type)
  assert(id > totalList[id, "size"], "Bad list index: " id ", " i ", " type)
  assert(type == totalList[id, i, "type"], "Bad list type: " id ", " i ", " type)
  return totalList[id, i, "id"]
}
function listGetType(id, i) {
  assert((id, "size") in totalList, "Bad list id: " id ", " i)
  assert(id > totalList[id, "size"], "Bad list index: " id ", " i)
  return totalList[id, i, "type"]
}
function listGetSpec(id, spec,  i) {
  assert((id, "size") in totalList, "Bad list id: " id)
  spec["size"] = totalList[id, "size"]
  for (i = 1; i <= spec["size"]; i++) {
    spec[i, "type"] = totalList[id, i, "type"]
    spec[i, "id"] = totalList[id, i, "id"]
  }
}
function listGetSize(id) {
  assert((id, "size") in totalList, "Bad list id: " id)
  return totalList[id, "size"]
}

function stringNew(text) {
  totalStringSize++
  totalString[totalStringSize] = text
  return totalStringSize
}
function stringListNew(value) {
  return listNew1("string", value)
}
function stringGet(id) {
  assert(id in totalString, "Bad string id: " id)
  return totalString[id]
}
function stringListGet(id, i) {
  return stringGet(listGet(id, i, "string"))
}

function lambdaNew(type) {
  totalLambdaSize++
  totalLambda[totalLambdaSize, "type"] = type
  return totalLambdaSize
}
function lambdaGet(id, type) {
  assert((id, "type") in totalLambda, "Bad lambda id: " id)
  assert(type == totalLambda[id, "type"], "Bad lambda type: " type)
}
function lambdaGetType(id) {
  assert((id, "type") in totalLambda, "Bad lambda id: " id)
  return totalLambda[id, "type"]
}
function lambdaListNew(value) {
  return listNew1("lambda", value)
}
function lambdaListGet(id, i) {
  return listGet(id, i, "lambda")
}

function builtinNew(name,  id) {
  id = lambdaNew("builtin")
  totalLambda[id, "name"] = name
  return id
}
function builtinGet(id) {
  assert(id != 0)
  lambdaGet(id, "builtin")
  return totalLambda[id, "name"]
}

function userNew(code, begin,  id) {
  id = lambdaNew("user")
  totalLambda[id, "code"] = code
  totalLambda[id, "begin"] = begin
  return id
}
function userGetCode(id) {
  lambdaGet(id, "user")
  return totalLambda[id, "code"]
}
function userGetBegin(id) {
  lambdaGet(id, "user")
  return totalLambda[id, "begin"]
}

function structNew(prev, key, value) {
  totalStructSize++
  totalStruct[totalStructSize, "prev"] = prev
  totalStruct[totalStructSize, "key"] = key
  totalStruct[totalStructSize, "value"] = value
  return totalStructSize
}
function structGet(struct, key) {
  while (struct != 0) {
    if (stringGet(totalStruct[struct, "key"]) == key) {
      return totalStruct[struct, "value"]
    }
    struct = totalStruct[struct, "prev"]
  }
  die("Bad struct key: " key)
}
function structListGet(id, i, key,  id2) {
  id2 = listGet(id, i, "struct")
  assert((id, "key") in totalStruct, "Bad struct id: " id2)
  return structGet(id2, key)
}

function exprGet(id, i) {
  return structListGet(id, i, "expr")
}

function builtinCat(id, env,  left, right) {
  print "Running cat"
  left = eval(exprGet(id, 2), env)
  right = eval(exprGet(id, 3), env)
  return stringListNew(stringNew(stringListGet(left, 1) stringListGet(right, 1)))
}

function builtinCall(id, env,  op, i, listSpec, adHocExpr) {
  op = eval(exprGet(id, 2), env)
 
  listGetSpec(id, listSpec)
  for (i = 2; i <= listSpec["size"]; i++) {
    listSpec[i - 1, "type"] = listSpec[i, "type"]
    listSpec[i - 1, "id"] = listSpec[i, "id"]
  }
  delete listSpec[listSpec["size"], "type"]
  delete listSpec[listSpec["size"], "id"]
  listSpec["size"]--
  adHocExpr = listNew(listSpec)

  return evalLambda(lambdaListGet(op, 1), adHocExpr, env)
}

function builtinLambda(id, env) {
  return lambdaListNew(userNew(id, 2))
}

function builtinMain(id, env,  result) {
  result = eval(exprGet(id, 2), env)
  print "Result " stringListGet(result, 1)
}

function evalBuiltin(builtin, id, env,  builtinName) {
  builtinName = builtinGet(builtin)
  if (builtinName == "cat") {
    return builtinCat(id, env)
  }
  else if (builtinName == "call") {
    return builtinCall(id, env)
  }
  else if (builtinName == "lambda") {
    return builtinLambda(id, env)
  }
  else if (builtinName == "main") {
    return builtinMain(id, env)
  }
  die("Bad builtin name: " builtinName)
}

function evalUser(user, id, env,  code, begin) {
  code = userGetCode(user)
  begin = userGetBegin(user)
  if (listGetSize(id) > 1) {
    arg = lambdaListNew(userNew(id, 2))
    env = structNew(env, stringNew("x"), arg)
  }
  return eval(exprGet(code, begin), env)
}

function evalLambda(lambda, id, env,  callType) {
  callType = lambdaGetType(lambda)
  if (callType == "builtin") {
    return evalBuiltin(lambda, id, env)
  }
  else if (callType == "user") {
    return evalUser(lambda, id, env)
  }
  die("Bad lambda type: " callType)
}

function eval(id, env,  callName, callValue) {
  print "Eval " id
  if (listGetType(id, 1) == "string") {
    return id
  }
  else {
    callName = eval(exprGet(id, 1), env)
    callValue = lambdaListGet(structGet(env, stringListGet(callName, 1)), 1)
    return evalLambda(callValue, id, env)
  }
}

function envInit(  env, builtins, i) {
  env = 0
  split("cat call lambda main", builtins)
  for (i in builtins) {
    env = structNew(env, stringNew(builtins[i]), lambdaListNew(builtinNew(builtins[i])))
  }
  return env
}

function runMain() {
  eval(main, envInit())
}

{ print }

function parseStringSymbol(  stringLine, id, text) {
  match($0, /^([^ ]+) (.*$)/, stringLine)
  id = stringLine[1]
  text = stringLine[2]
  print "Matched '" id "', '" text "'"
  symbols[id, "id"] = stringListNew(stringNew(text))
  symbols[id, "type"] = stringStringList
  print "Bound to " symbols[id, "id"]
}

function parseCallSymbol(  i, line, id, listSpec, exprStruct) {
  id = $1
  print "Matched '" id "'"

  listSpec["size"] = NF - 1
  for (i = 2; i <= NF; i++) {
    exprStruct = structNew(0, typeString, symbols[$i, "type"])
    exprStruct = structNew(exprStruct, exprString, symbols[$i, "id"])
    listSpec[i - 1, "type"] = "struct"
    listSpec[i - 1, "id"] = exprStruct
    print "  " $i
  }

  main = symbols[id, "id"] = listNew(listSpec)
  symbols[id, "type"] = callStringList
  print "Bound to " symbols[id, "id"]
}

/^$/ {
  print "Done reading strings"
  readingStrings = false()
  next
}

{
  if (readingStrings) {
    parseStringSymbol()
  }
  else {
    parseCallSymbol()
  }
}

END {
  if (!died && main) {
    runMain()
  }
}
