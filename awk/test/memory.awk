@use("../lib/memory")
@use("./check")

@check("basic string", \
  x) \
{
  x = string_new("hello")
  check_matches(string_get(x), "hello")
}
