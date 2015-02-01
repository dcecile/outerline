@use("./memory")

function expr_new_string( \
  string \
  ) \
{
  return record_new2( \
    "type", list_new1(string_new("string")), \
    "string", string)
}

function expr_new_call( \
  call \
  ) \
{
  return record_new2( \
    "type", list_new1(string_new("call")), \
    "call", call)
}

function expr_new_block( \
  args \
  ) \
{
  return record_new2( \
    "type", list_new1(string_new("block")), \
    "args", args)
}

function expr_find_all_args( \
  blocks, \
  all_args, i, j) \
{
  all_args = list_new0()

  for (i = blocks; !list_is_empty(i); i = list_rest(i)) {
    for (j = record_get(list_first(i), "args"); !list_is_empty(j); j = list_rest(j)) {
      list_add(all_args, list_first(j))
    }
  }

  return all_args
}
