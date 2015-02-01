@use("./memory")

function builtin_cat( \
  blocks, env, caller_env, cont \
  ) \
{
  if (!list_is_single(blocks)) {
    fail("expected one block for builtin 'cat'")
  }

  return eval_args( \
    list_new0(), \
    record_get(list_first(blocks), "args"), \
    env, \
    cont_new2("builtin_cat_cont", \
      "caller_env", caller_env, \
      "cont", cont))
}

function builtin_cat_cont( \
  cont, value, env, \
  result) \
{
  result = ""
  while (!list_is_empty(value)) {
    if (!memory_is_string(list_first(value))) {
      fail("expected all strings for builtin 'cat'")
    }
    result = result string_get(list_first(value))
    value = list_rest(value)
  }

  return call_cont( \
    record_get(cont, "cont"), \
    list_new1(string_new(result)), \
    record_get(cont, "caller_env"))
}

function builtin_var( \
  blocks, env, caller_env, cont \
  ) \
{
  if (!list_is_single(blocks)) {
    fail("expected one block for builtin 'var'")
  }

  return eval_args( \
    list_new0(), \
    record_get(list_first(blocks), "args"), \
    env, \
    cont_new2("builtin_var_cont", \
      "caller_env", caller_env, \
      "cont", cont))
}

function builtin_var_cont( \
  cont, value, env, \
  name, result) \
{
  if (list_is_empty(value) || !memory_is_string(list_first(value))) {
    fail("expected string name argument for builtin 'var'")
  }

  name = string_get(list_first(value))
  result = list_rest(value)

  return call_cont( \
    record_get(cont, "cont"), \
    result, \
    env_xtn_var(record_get(cont, "caller_env"), name, result))
}
