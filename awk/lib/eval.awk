@use("./memory")
@use("./cont")
@use("./builtin")
@use("./switch")
@use("./env")

function eval( \
  code, env, cont, \
  value, first, type, rest, call, call_name, call_args) \
{
  # Snap up all the string constants
  value = list_new0()
  while (!list_is_empty(code) && variant_get(list_first(code)) == "string") {
    list_add(value, list_first(record_get(list_first(code), "string")))
    code = list_rest(code)
  }

  # If nothing else, call the continuation
  if (list_is_empty(code)) {
    return call_cont(cont, value, env)
  }
  else {

    # Otherwise, look at the first call to evaluate
    first = list_first(code)
    type = variant_get(first)
    rest = list_rest(code)
    if (type == "call") {

      # Separate out the call name and call arguments
      call = record_get(first, "call")
      call_name = list_new1(list_first(call))
      call_args = list_rest(call)

      # Evaluate the call name before actually making the call
      return eval( \
        call_name, \
        env_push(env), \
        cont_new5("eval_cont_call_get_name", \
          "value", value, \
          "args", call_args, \
          "caller_env", env, \
          "rest", rest, \
          "cont", cont))
    }
    else {
      fail("uknown expression type: " type)
    }
  }
}

function eval_cont_call_get_name( \
  cont, value, env, \
  name, search, type) \
{
  if (list_length(value) != 1 || !memory_is_string(list_first(value))) {
    return cont_fail("expected one string for a call name", cont)
  }
  else {

    # Now that the name is calculated, find and call the function
    name = string_get(list_first(value))
    env_try_get(env, name, search)

    # If found in the environment, try to evaluate it
    if (search["found"]) {
      type = string_get(list_first(record_get(search["binding"], "type")))

      # Variables can be immediately feed into the next stage
      if (type == "var") {
        return eval_cont_call_get_value( \
          cont, \
          record_get(search["binding"], "value"), \
          env)
      }
      else {
        fail("uknown environment binding type: " type)
      }
    }

    # Otherwise, try to call it as a builtin
    else {
      return call_builtin( \
        name, \
        record_get(cont, "args"), \
        env, \
        record_get(cont, "caller_env"), \
        cont_new3("eval_cont_call_get_value",
          "value", record_get(cont, "value"), \
          "rest", record_get(cont, "rest"), \
          "cont", record_get(cont, "cont")))
    }
  }
}

function eval_cont_call_get_value( \
  cont, value, env \
  ) \
{
  value = list_append( \
    record_get(cont, "value"), \
    value)

  if (list_is_empty(value)) {
    # Directly return the results from the rest of the expression,
    # since the call didn't yield any values
    return eval( \
      record_get(cont, "rest"), \
      env, \
      record_get(cont, "cont"))
  }
  else {
    # Once the rest of the expression is evaluated, append the result
    # to the value returned by the call that just finished
    return eval( \
      record_get(cont, "rest"), \
      env, \
      cont_new2("eval_cont_append", \
        "value", value, \
        "cont", record_get(cont, "cont")))
  }
}

function eval_cont_append( \
  cont, value, env \
  ) \
{
  # Append, and continue
  return call_cont( \
    record_get(cont, "cont"), \
    list_append( \
      record_get(cont, "value"), \
      value), \
    env)
}

function eval_get_value( \
  code, env, \
  result) \
{
  result = eval(code, env, \
    cont_new0("eval_get_value_cont"))

  if (variant_get(result) != "done") {
    fail("unknown continuation result: " variant_get(result))
  }

  return record_get(result, "value")
}

function eval_get_value_cont( \
  cont, value, env \
  ) \
{
  return record_new2( \
    "type", list_new1(string_new("done")), \
    "value", value)
}
