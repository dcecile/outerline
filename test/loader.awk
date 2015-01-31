@use("../src/loader")
@use("./check")

function check_loader_call_expr( \
  expr \
  ) \
{
  check_matches( \
    record_has(expr, "type"), \
    true())
  check_matches( \
    string_get(list_first(record_get(expr, "type"))), \
    "call")
  check_matches( \
    record_has(expr, "call"), \
    true())
}

function check_loader_string_expr( \
  expr, text \
  ) \
{
  check_matches( \
    record_has(expr, "type"), \
    true())
  check_matches( \
    string_get(list_first(record_get(expr, "type"))), \
    "string")
  check_matches( \
    record_has(expr, "string"), \
    true())
  check_matches( \
    string_get(list_first(record_get(expr, "string"))), \
    text)
}

@check("basic loading", \
  all, all1, root, root1, root2, root3, cat, cat1, cat2, cat3) \
{
  all = load_text( \
    "0 dog" NL \
    "1 bird" NL \
    "2 cat" NL \
    "3 lizard" NL \
    "" NL \
    "4 2 3 1" NL \
    "5 2 0 4")

  # Should become
  #
  # (rec;
  #   type, call;
  #   call,
  #     (rec;
  #       type, string;
  #       string, cat)
  #     (rec;
  #       type, string;
  #       string, dog)
  #     (rec;
  #       type, call;
  #       call,
  #         (rec;
  #           type, string;
  #           string, cat)
  #         (rec;
  #           type, string;
  #           string, lizard)
  #         (rec;
  #           type, string;
  #           string, bird)))

  check_matches(list_length(all), 1)
  all1 = list_first(all)
  check_loader_call_expr(all1)

  root = record_get(all1, "call")
  check_matches(list_length(root), 3)
  root1 = list_first(root)
  root2 = list_first(list_rest(root))
  root3 = list_first(list_rest(list_rest(root)))
  check_loader_string_expr(root1, "cat")
  check_loader_string_expr(root2, "dog")
  check_loader_call_expr(root3)

  cat = record_get(root3, "call")
  check_matches(list_length(cat), 3)
  cat1 = list_first(cat)
  cat2 = list_first(list_rest(cat))
  cat3 = list_first(list_rest(list_rest(cat)))
  check_loader_string_expr(cat1, "cat")
  check_loader_string_expr(cat2, "lizard")
  check_loader_string_expr(cat3, "bird")
}
