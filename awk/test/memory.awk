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
  x = list_new0()
  list_add(x, string_new("a"))
  list_add(x, string_new("b"))

  y = list_new1(string_new("c"))

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
            list_new1(string_new("a")), \
            list_new1(string_new("b"))), \
          list_new1(string_new("c"))), \
        list_new1(string_new("d"))), \
      list_new1(string_new("e")))

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
      list_new1(string_new("a")), \
      list_append( \
        list_new1(string_new("b")), \
        list_append( \
          list_new1(string_new("c")), \
          list_append( \
            list_new1(string_new("d")), \
            list_new1(string_new("e"))))))

  y["length"] = 5
  y[1] = "a"
  y[2] = "b"
  y[3] = "c"
  y[4] = "d"
  y[5] = "e"

  check_list_matches(x, y)
  check_list_matches(x, y)
}

@check("basic record", \
  x, y, z ) \
{
  x = record_new0()
  record_add(x, \
    "a", \
    list_new1(string_new("b")))
  record_add(x, \
    "c", \
    list_new1(string_new("d")))

  y = record_new1( \
    "e", \
    list_new1(string_new("f")))

  z = record_new2( \
    "g", \
    list_new1(string_new("h")), \
    "i", \
    list_new1(string_new("j")))

  check_matches( \
    record_has(x, "a"),
    true())
  check_matches( \
    record_has(x, "e"),
    false())
  check_matches( \
    string_get(list_first(record_get(x, "a"))),
    "b")
  check_matches( \
    string_get(list_first(record_get(x, "c"))),
    "d")

  check_matches( \
    record_has(y, "e"),
    true())
  check_matches( \
    record_has(y, "g"),
    false())
  check_matches( \
    string_get(list_first(record_get(y, "e"))),
    "f")

  check_matches( \
    record_has(z, "g"),
    true())
  check_matches( \
    record_has(z, "a"),
    false())
  check_matches( \
    string_get(list_first(record_get(z, "g"))),
    "h")
  check_matches( \
    string_get(list_first(record_get(z, "i"))),
    "j")
}

@check("basic record extend", \
  x, y, z ) \
{
  x = record_new2( \
    "a", list_new1(string_new("b")), \
    "c", list_new1(string_new("d")))

  y = record_xtn2( \
    x, \
    "e", list_new1(string_new("f")), \
    "a", list_new1(string_new("g")))


  check_matches( \
    record_has(y, "a"),
    true())
  check_matches( \
    record_has(y, "c"),
    true())
  check_matches( \
    record_has(y, "e"),
    true())
  check_matches( \
    record_has(y, "i"),
    false())
  check_matches( \
    string_get(list_first(record_get(y, "a"))),
    "g")
  check_matches( \
    string_get(list_first(record_get(y, "c"))),
    "d")
  check_matches( \
    string_get(list_first(record_get(y, "e"))),
    "f")
}
