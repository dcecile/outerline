@use("./memory")

function builtin_cat( \
  args, env, cont \
  ) \
{
  return eval(args, env, \
    cont_new1("builtin_cat_cont",
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
  return call_cont(cont2, list_new1(string_new(result)), env)
}
