BEGIN {
  strings = 1
  "" in symbols
  main = ""
  totalEnvSize = 0
  "" in totalEnv
  builtinEnv = 0
  envInit()
  totalMemSize = 0
  "" in totalMem
}

function envInit(builtins) {
  split("cat chain var", builtins)
  for (i in builtins) {
    builtinEnv = envAddBuiltin(builtinEnv, builtins[i])
  }
}

function envAddBuiltin(env, name) {
  totalEnvSize++
  totalEnv[totalEnvSize, "prev"] = env
  totalEnv[totalEnvSize, "name"] = name
  totalEnv[totalEnvSize, "type"] = "builtin"
  return totalEnvSize
}

function envAddLambda(env, name, id, boundEnv) {
  totalEnvSize++
  totalEnv[totalEnvSize, "prev"] = env
  totalEnv[totalEnvSize, "name"] = name
  totalEnv[totalEnvSize, "type"] = "lambda"
  totalEnv[totalEnvSize, "id"] = id
  totalEnv[totalEnvSize, "boundEnv"] = boundEnv
  return totalEnvSize
}

function envAddValue(env, name, value) {
  totalEnvSize++
  totalEnv[totalEnvSize, "prev"] = env
  totalEnv[totalEnvSize, "name"] = name
  totalEnv[totalEnvSize, "type"] = "value"
  totalEnv[totalEnvSize, "value"] = value
  return totalEnvSize
}

function envGet(env, name) {
  while (env != 0) {
    if (totalEnv[env, "name"] == name) {
      return env
    }
    else {
      env = totalEnv[env, "prev"]
    }
  }
  print "Couldn't find '" name "'!" > "/dev/stderr"
  return 0
}

function evalChain(id, env, result) {
  eval(symbols[id, 2], env, result)
  env = result["env"]
  eval(symbols[id, 3], env, result)
}

function evalVar(id, env, result,  nameResult, valueResult, value) {
  eval(symbols[id, 2], env, nameResult)
  eval(symbols[id, 3], nameResult["env"], valueResult)
  result["value"] = valueResult["value"]
  result["env"] = envAddValue(env, nameResult["value"], valueResult["value"])
}

function eval(id, env, result,  type, opResult, size, i, args, op) {
  print "Eval " id
  type = symbols[id, "type"]

  if (type == "string") {
    result["value"] = symbols[id, "text"]
    result["env"] = env
  }
  else if (type == "call") {

    eval(symbols[id, 1], env, opResult)
    env = opResult["env"]

    name = opResult["value"]
    op = envGet(env, name)

    if (totalEnv[op, "type"] == "builtin") {
      if (name == "cat") {
        evalCat(id, env, result)
      }
      else if (name == "var") {
        evalVar(id, env, result)
      }
      else if (name == "chain") {
        evalChain(id, env, result)
      }
      else {
        print "Unknown builtin!"
      }
    }
    else if (totalEnv[op, "type"] == "value") {
      result["value"] = totalEnv[op, "value"]
      result["env"] = env
    }
    else {
      print "Unknown type!"
    }
  }
}

function runMain(result) {
  eval(main, builtinEnv, result)
  print "Result " result["value"]
}

{ print }

function addString(  line, id, text) {
  match($0, /^([^ ]+) (.*$)/, line)
  id = line[1]
  text = line[2]
  print "Matched '" id "', '" text "'"
  symbols[id, "type"] = "string"
  symbols[id, "text"] = text
}

function addCall(  i, line, id, text) {
  id = $1
  print "Matched '" id "'"
  symbols[id, "type"] = "call"
  symbols[id, "size"] = NF - 1
  for (i = 2; i <= NF; i++) {
    symbols[id, i - 1] = $i
    print "  " $i
  }
  main = id
}

/^$/ {
  print "Done strings"
  strings = 0
  next
}

{
  if (strings) {
    addString()
  }
  else {
    addCall()
  }
}

END {
  if (main) {
    runMain()
  }
}
