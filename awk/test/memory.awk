@use("../lib/memory")
@use("./check")

@check("basic string", \
  ) \
{
  check_matches( \
    string_get(string_new("hello")), \
    "hello")
  check_matches( \
    string_get(string_new("bye")), \
    "bye")
  check_matches( \
    string_get(string_new("hello")), \
    "hello")
}

@check("basic list", \
  x, y) \
{
  x = list_new()
  list_add(x, string_new("a"))
  list_add(x, string_new("b"))
  check_matches( \
    list_length(x), \
    2)
  check_matches( \
    list_is_empty(x), \
    false())
  check_matches( \
    string_get(list_first(x)), \
    "a")
  check_matches( \
    list_is_empty(list_rest(x)), \
    false())
  check_matches( \
    list_length(list_rest(x)), \
    1)
  check_matches( \
    string_get(list_first(list_rest(x))), \
    "b")
  check_matches( \
    list_is_empty(list_rest(list_rest(x))), \
    true())
  check_matches( \
    list_length(list_rest(list_rest(x))), \
    0)

  y = list_single(string_new("c"))
  check_matches( \
    list_length(y), \
    1)
  check_matches( \
    list_is_empty(y), \
    false())
  check_matches( \
    string_get(list_first(y)), \
    "c")
}

function check_list_matches( \
  x, y, \
  i) \
{
  i = 0
  while (!list_is_empty(x)) {
    i += 1
    check_matches( \
      list_length(x), \
      y["length"] - i + 1)
    check_matches( \
      string_get(list_first(x)), \
      y[i])
    x = list_rest(x)
  }

  check_matches( \
    list_length(x), \
    0)
  check_matches( \
    i, \
    y["length"])
}

@check("tail append", \
  x, y, i ) \
{
  x = \
    list_append( \
      list_append( \
        list_append( \
          list_append( \
            list_single(string_new("a")), \
            list_single(string_new("b"))), \
          list_single(string_new("c"))), \
        list_single(string_new("d"))), \
      list_single(string_new("e")))

  y["length"] = 5
  y[1] = "a"
  y[2] = "b"
  y[3] = "c"
  y[4] = "d"
  y[5] = "e"

  check_list_matches(x, y)
  check_list_matches(x, y)
}

@check("head append", \
  x, y, i ) \
{
  x = \
    list_append( \
      list_single(string_new("a")), \
      list_append( \
        list_single(string_new("b")), \
        list_append( \
          list_single(string_new("c")), \
          list_append( \
            list_single(string_new("d")), \
            list_single(string_new("e"))))))

  y["length"] = 5
  y[1] = "a"
  y[2] = "b"
  y[3] = "c"
  y[4] = "d"
  y[5] = "e"

  check_list_matches(x, y)
  check_list_matches(x, y)
}
