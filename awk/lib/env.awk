@use("./memory")

function env_new0( \
  \
  ) \
{
  return env_push(list_new0())
}

function env_push( \
  env \
  ) \
{
  return list_append(list_new1(record_new0()), env)
}

function env_xtn( \
  env, name, binding, \
  first, rest) \
{
  first = list_first(env)
  rest = list_rest(env)
  return list_append( \
    list_new1(record_xtn1(first, name, binding)), \
    rest)
}

function env_xtn_var( \
  env, name, value \
  ) \
{
  return env_xtn( \
    env, \
    name, \
    list_new1(record_new2( \
      "type", list_new1(string_new("var")),
      "value", value)))
}

function env_try_get( \
  env, name, result, \
  first, rest) \
{
  while (!list_is_empty(env)) {
    first = list_first(env)
    if (record_has(first, name)) {
      result["found"] = true()
      result["closure"] = env
      result["binding"] = list_first(record_get(first, name))
      return
    }
    else {
      env = list_rest(env)
    }
  }
  result["found"] = false()
}
