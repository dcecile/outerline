function call_builtin( \
  name, blocks, env, caller_env, cont \
  ) \
{
  if (name == "cat") {
    return builtin_cat(blocks, env, caller_env, cont)
  }
  if (name == "var") {
    return builtin_var(blocks, env, caller_env, cont)
  }
  else {
    return fail("undefined variable/function: " name)
  }
}

function call_cont( \
  cont, value, env, \
  name) \
{
  cont = list_first(cont)
  name = string_get(list_first(record_get(cont, "name")))

  if (name == "eval_cont_call_get_name") {
    return eval_cont_call_get_name(cont, value, env)
  }
  else if (name == "eval_cont_call_get_value") {
    return eval_cont_call_get_value(cont, value, env)
  }
  else if (name == "eval_cont_append") {
    return eval_cont_append(cont, value, env)
  }
  else if (name == "eval_root_cont") {
    return eval_root_cont(cont, value, env)
  }
  else if (name == "builtin_cat_cont") {
    return builtin_cat_cont(cont, value, env)
  }
  else if (name == "builtin_var_cont") {
    return builtin_var_cont(cont, value, env)
  }
  else {
    fail("unknown continuation: " name)
  }
}
