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
