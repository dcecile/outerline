@use("./memory")
@use("./cont")
@use("./builtin")
@use("./switch")
@use("./env")

function eval_args( \
  value, args, env, cont, \
  first, type, rest, call, call_name, call_blocks) \
{
  # Snap up all the string constants
  while (!list_is_empty(args) && variant_get(list_first(args)) == "string") {
    value = list_append(value, record_get(list_first(args), "string"))
    args = list_rest(args)
  }

  # If nothing else, call the continuation
  if (list_is_empty(args)) {
    return call_cont(cont, value, env)
  }
  else {

    # Otherwise, look at the first call to evaluate
    first = list_first(args)
    type = variant_get(first)
    rest = list_rest(args)
    if (type == "call") {

      # Separate out the call name and call blocks
      call = record_get(first, "call")
      call_name = record_get(list_first(call), "args")
      call_blocks = list_rest(call)

      # Evaluate the call name before actually making the call
      return eval_args( \
        list_new0(), \
        call_name, \
        env_push(env), \
        cont_new5("eval_cont_call_get_name", \
          "value", value, \
          "blocks", call_blocks, \
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
  blocks, name, search, binding, type) \
{
  if (!list_is_single(value) || !memory_is_string(list_first(value))) {
    fail("expected one string for a call name")
  }

  # Now that the name is calculated, find and call the function
  blocks = record_get(cont, "blocks")
  name = string_get(list_first(value))
  env_try_get(env, name, search)

  if (search["found"]) {
    # If found in the environment, try to evaluate it
    binding = search["binding"]
    type = string_get(list_first(record_get(binding, "type")))

    # Variables can be immediately feed into the next stage
    if (type == "var") {
      if (!list_is_empty(blocks)) {
        fail("expected no blocks for variable evaluation: " name);
      }
      return eval_args( \
        list_append(record_get(cont, "value"), record_get(binding, "value")), \
        record_get(cont, "rest"), \
        record_get(cont, "caller_env"), \
        record_get(cont, "cont"))
    }
    else {
      fail("uknown environment binding type: " type)
    }
  }
  else {
    # Otherwise, try to call it as a builtin,
    # then continue evaluating the other arguments
    return call_builtin( \
      name, \
      blocks, \
      env, \
      record_get(cont, "caller_env"), \
      cont_new3("eval_cont_call_get_value",
        "value", record_get(cont, "value"), \
        "rest", record_get(cont, "rest"), \
        "cont", record_get(cont, "cont")))
  }
}

function eval_cont_call_get_value( \
  cont, value, env \
  ) \
{
  # Append the new call results
  value = list_append( \
    record_get(cont, "value"), \
    value)

  # Continue evaluating
  return eval_args( \
    value, \
    record_get(cont, "rest"), \
    env, \
    record_get(cont, "cont"))
}

function eval_root( \
  blocks, \
  result) \
{
  result = eval_args( \
    list_new0(), \
    expr_find_all_args(blocks), \
    env_new0(), \
    cont_new0("eval_root_cont"))

  if (variant_get(result) != "done") {
    fail("unknown continuation result: " variant_get(result))
  }

  return record_get(result, "value")
}

function eval_root_cont( \
  cont, value, env \
  ) \
{
  return record_new2( \
    "type", list_new1(string_new("done")), \
    "value", value)
}
