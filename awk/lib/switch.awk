function call_builtin( \
  name, args, env, cont \
  ) \
{
  if (name == "cat") {
    return builtin_cat(args, env, cont)
  }
  else {
    return cont_fail("undefined variable/function: " name)
  }
}

function call_cont( \
  cont, value, env, \
  name) \
{
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
  else if (name == "eval_get_value_cont") {
    return eval_get_value_cont(cont, value, env)
  }
  else if (name == "builtin_cat_cont") {
    return builtin_cat_cont(cont, value, env)
  }
  else {
    fail("unknown continuation: " name)
  }
}
