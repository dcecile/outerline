@use("../lib/expr")
@use("../lib/loader")
@use("../lib/env")
@use("../lib/eval")
@use("./check")

@check("basic string eval", \
  x_e, x_r, y_e, y_r) \
{
  x_e = list_new1(expr_new_string( \
    list_new1(string_new("a"))))
  x_r = eval_get_value(x_e, env_new0())

  y_e = list_new0()
  list_add(y_e, expr_new_string( \
    list_new1(string_new("b"))))
  list_add(y_e, expr_new_string( \
    list_new1(string_new("c"))))
  y_r = eval_get_value(y_e, env_new0())

  check_matches( \
    list_length(x_r), \
    1)
  check_matches( \
    string_get(list_first(x_r)), \
    "a")

  check_matches( \
    list_length(y_r), \
    2)
  check_matches( \
    string_get(list_first(y_r)), \
    "b")
  check_matches( \
    string_get(list_first(list_rest(y_r))), \
    "c")
}

@check("basic call eval", \
  x_c_e, x_e, x_r) \
{
  x_c_e = list_new0()
  list_add(x_c_e, expr_new_string( \
    list_new1(string_new("cat"))))
  list_add(x_c_e, expr_new_string( \
    list_new1(string_new("abc"))))
  list_add(x_c_e, expr_new_string( \
    list_new1(string_new("def"))))
  x_e = list_new1(expr_new_call(x_c_e))

  x_r = eval_get_value(x_e, env_new0())

  check_matches( \
    list_length(x_r), \
    1)
  check_matches( \
    string_get(list_first(x_r)), \
    "abcdef")
}

@check("nested call eval", \
  x_e, x_r) \
{
  x_e = load_text( \
    "0 cat" NL \
    "1 a" NL \
    "2 b" NL \
    "3 c" NL \
    "4 d" NL \
    "" NL \
    "5 0 2 3" NL \
    "6 0 1 5 4")
  x_r = eval_get_value(x_e, env_new0())

  check_matches( \
    list_length(x_r), \
    1)
  check_matches( \
    string_get(list_first(x_r)), \
    "abcd")
}
