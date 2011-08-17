BEGIN {
  died = false()
  readingStrings = true()
  "" in compressedExpressions
  main = ""

  "" in memory
  memorySize = 0

  "" in symbols
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
function assertId(condition, message, id) {
  assert(condition, id ": " message)
}
function dieId(message, id) {
  assertId(false(), message, id)
}

function genericNew(type,  id) {
  id = ++memorySize
  assertId(!((id, "type") in memory), "In use", id)
  memory[id, "type"] = type
  print ">> " id " (" type ")"
  return id
}
function genericAssertType(id, type) {
  assertId((id, "type") in memory, "Invalid reference", id)
  assertId(memory[id, "type"] == type, "Not of type " type, id)
}
function genericGet(id, type, field) {
  genericAssertType(id, type)
  assertId((id, field) in memory, "Invalid field " field, id)
  return memory[id, field]
}
function genericSet(id, type, field, value) {
  genericAssertType(id, type)
  memory[id, field] = value
}

function listNew(spec,  id, i) {
  id = genericNew("list")
  genericSet(id, "list", "size", spec["size"])
  for (i = 1; i <= spec["size"]; i++) {
    genericSet(id, "list", i, spec[i])
  }
  return id
}
function listNew1(value,  listSpec) {
  listSpec["size"] = 1
  listSpec[1] = value
  return listNew(listSpec)
}
function listGet(id, i,  size) {
  size = listGetSize(id)
  assertId(i <= size, "Index out of range: " i, id)
  return genericGet(id, "list", i)
}
function listGetSize(id) {
  return genericGet(id, "list", "size")
}
function listAssertSize(id, size) {
  assertId(listGetSize(id) == size, "Expected size: " size, id)
}
function listGetSingle(id) {
  listAssertSize(id, 1)
  return listGet(id, 1)
}

function stringNew(text,  id) {
  id = genericNew("string")
  genericSet(id, "string", "text", text)
  genericSet(id, "string", "symbol", 0)
  return id
}
function stringGetText(id) {
  return genericGet(id, "string", "text")
}
function stringGetSymbol(id,  text, symbol) {
  symbol = genericGet(id, "string", "symbol")
  if (symbol == 0) {
    text = stringGetText(id)
    if (!(text in symbols)) {
      symbol = listNew1(id)
      symbols[text] = symbol
    }
    else {
      symbol = symbols[text]
    }
    genericSet(id, "string", "symbol", symbol)
  }
  return symbol
}

function symbolNew(text) {
  if (!(text in symbols)) {
    return stringGetSymbol(\
      stringNew(text))
  }
  else {
    return symbols[text]
  }
}
function symbolNewString(text) {
  return listGet(symbolNew(text), 1)
}

function builtinNew(name,  id) {
  id = genericNew("builtin")
  genericSet(id, "builtin", "name", name)
  return id
}
function builtinGet(id) {
  return genericGet(id, "builtin", "name")
}

function lambdaNew(code, closure,  id) {
  id = genericNew("lambda")
  genericSet(id, "lambda", "code", code)
  genericSet(id, "lambda", "closure", closure)
  return id
}
function lambdaGetCode(id) {
  return genericGet(id, "lambda", "code")
}
function lambdaGetClosure(id) {
  return genericGet(id, "lambda", "closure")
}

function constantNew(value,  id) {
  id = genericNew("constant")
  genericSet(id, "constant", "value", value)
  return id
}
function constantGet(id) {
  return genericGet(id, "constant", "value")
}

function recordNew(prev, key, value,  id) {
  genericAssertType(value, "list")
  id = genericNew("record")
  genericSet(id, "record", "prev", prev)
  genericSet(id, "record", "key", stringGetSymbol(key))
  genericSet(id, "record", "value", value)
  return id
}
function recordTryGet(id, key,  keySymbol) {
  keySymbol = stringGetSymbol(key)
  do {
    if (genericGet(id, "record", "key") == keySymbol) {
      return genericGet(id, "record", "value")
    }
    id = genericGet(id, "record", "prev")
  }
  while (id != 0)
  return 0
}
function recordGet(id, key,  value) {
  value = recordTryGet(id, key)
  assertId(value != 0, "Bad struct key: " key, id)
  return value
}

function exprNew(type, value) {
  return recordNew(\
      recordNew(0,\
        symbolNewString("type"), symbolNew(type)),\
      symbolNewString("value"), value)
}

function eval(expr,  rec, type) {
  rec = listGetSingle(expr, 1)
  type = stringGetText(listGetSingle(\
    recordGet(rec, symbolNewString("type"))))
  if (type == "string") {
    resultValue = recordGet(rec, symbolNewString("value"))
    resultEnv = resultEnv
  }
  else {
    dieId("Unknown expression type", expr)
  }
}

function runMain() {
  resultValue = main
  resultEnv = 0
  continuation = "eval"
  continuationLoop()
}

{ print }

function parseStringSymbol(  code, text, id) {
  code = $1
  text = substr($0, length(code) + 2)
  print "Matched '" code "', '" text "'"
  id = listNew1(exprNew("string", listNew1(stringNew(text))))
  compressedExpressions[code] = id
  print "Bound to " id
}

function parseCallSymbol(  code, i, id, listSpec) {
  code = $1
  print "Matched '" code "'"
  listSpec["size"] = NF - 1
  for (i = 2; i <= NF; i++) {
    listSpec[i - 1] = compressedExpressions[$i]
    print "  " $i
  }
  id = listNew1(exprNew("call", listNew(listSpec)))
  compressedExpressions[code] = id
  print "Bound to " id
  main = id
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
