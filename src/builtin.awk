@use("./memory")

function builtin_cat( \
  args, args_env, caller_env, cont \
  ) \
{
  return eval(args, args_env, \
    cont_new2("builtin_cat_cont", \
      "caller_env", caller_env, \
      "cont", cont))
}

function builtin_cat_cont( \
  cont, value, env, \
  cont2, result) \
{
  cont2 = record_get(cont, "cont")
  result = ""
  while (!list_is_empty(value)) {
    if (!memory_is_string(list_first(value))) {
      return cont_fail("expected all strings for builtin 'cat'", cont2)
    }
    result = result string_get(list_first(value))
    value = list_rest(value)
  }
  return call_cont(cont2, list_new1(string_new(result)), record_get(cont, "caller_env"))
}

function builtin_var( \
  args, args_env, caller_env, cont \
  ) \
{
  return eval(args, args_env, \
    cont_new2("builtin_var_cont", \
      "caller_env", caller_env, \
      "cont", cont))
}

function builtin_var_cont( \
  cont, value, env, \
  cont2, name, result) \
{
  cont2 = record_get(cont, "cont")
  if (list_is_empty(value) || !memory_is_string(list_first(value))) {
    return cont_fail("expected string name argument for builtin 'var'", cont2)
  }
  name = string_get(list_first(value))
  result = list_rest(value)
  return call_cont( \
    cont2, \
    result, \
    env_xtn_var(record_get(cont, "caller_env"), name, result))
}
