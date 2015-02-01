@use("../src/expr")
@use("../src/parser")
@use("../src/env")
@use("../src/eval")
@use("./check")

@check("basic string eval", \
  input_a, result_a, input_b, result_b) \
{
  input_a = list_new1( \
    expr_new_string(list_new1(string_new("a"))))
  result_a = eval_root(list_new1(expr_new_block(input_a)))

  input_b = list_new2( \
    expr_new_string(list_new1(string_new("b"))), \
    expr_new_string(list_new1(string_new("c"))))
  result_b = eval_root(list_new1(expr_new_block(input_b)))

  check_matches( \
    list_length(result_a), \
    1)
  check_matches( \
    string_get(list_first(result_a)), \
    "a")

  check_matches( \
    list_length(result_b), \
    2)
  check_matches( \
    string_get(list_first(result_b)), \
    "b")
  check_matches( \
    string_get(list_first(list_rest(result_b))), \
    "c")
}

@check("basic call eval", \
  input, result) \
{
  input = list_new1(expr_new_call(list_new2( \
    expr_new_block(list_new1( \
      expr_new_string(list_new1(string_new("cat"))))), \
    expr_new_block(list_new2( \
      expr_new_string(list_new1(string_new("abc"))), \
      expr_new_string(list_new1(string_new("def"))))))))

  result = eval_root(list_new1(expr_new_block(input)))

  check_matches( \
    list_length(result), \
    1)
  check_matches( \
    string_get(list_first(result)), \
    "abcdef")
}

@check("nested call eval", \
  input, result) \
{
  input = list_new1(expr_new_call(list_new2( \
    expr_new_block(list_new1( \
      expr_new_string(list_new1(string_new("cat"))))), \
    expr_new_block(list_new3( \
      expr_new_string(list_new1(string_new("a"))), \
      expr_new_call(list_new2( \
        expr_new_block(list_new1( \
          expr_new_string(list_new1(string_new("cat"))))), \
        expr_new_block(list_new2( \
          expr_new_string(list_new1(string_new("b"))), \
          expr_new_string(list_new1(string_new("c"))))))), \
      expr_new_string(list_new1(string_new("d"))))))))

  result = eval_root(list_new1(expr_new_block(input)))

  check_matches( \
    list_length(result), \
    1)
  check_matches( \
    string_get(list_first(result)), \
    "abcd")
}

@check("basic env var", \
  input, result) \
{
  input = list_new1(expr_new_call(list_new2( \
    expr_new_block(list_new1( \
      expr_new_string(list_new1(string_new("cat"))))), \
    expr_new_block(list_new3( \
      expr_new_call(list_new2( \
        expr_new_block(list_new1( \
          expr_new_string(list_new1(string_new("var"))))), \
        expr_new_block(list_new2( \
          expr_new_string(list_new1(string_new("a"))), \
          expr_new_string(list_new1(string_new("b"))))))), \
      expr_new_string(list_new1(string_new("a"))), \
      expr_new_call(list_new1( \
        expr_new_block(list_new1( \
          expr_new_string(list_new1(string_new("a"))))))))))))

  result = eval_root(list_new1(expr_new_block(input)))

  check_matches( \
    list_length(result), \
    1)
  check_matches( \
    string_get(list_first(result)), \
    "bab")
}

@check("nested env var", \
  input, result) \
{
  input = parse_text( \
    "(cat;" NL \
    "  (var; a, b)," NL \
    "  (a)," NL \
    "  (cat;" NL \
    "    (a)," NL \
    "    (var; a, c)," NL \
    "    (var; d, e)," NL \
    "    (a)," NL \
    "    (d))," NL \
    "  (a))")

  result = eval_root(input)

  check_matches( \
    list_length(result), \
    1)
  check_matches( \
    string_get(list_first(result)), \
    "bbbceceb")
}
