@use("./utils")
@use("./memory")

function pretty_print( \
  id \
  ) \
{
  return pretty_print_with_indent(id, 0)
}

function pretty_print_awk_literal( \
  id, \
  result) \
{
  result = pretty_print(id)
  sub(/^/, "\"", result)
  gsub(/\n/, "\" NL \\\n\"", result)
  sub(/$/, "\"", result)
  return result
}

function pretty_build_indent( \
  indent, \
  result, i) \
{
  result = ""
  for (i = 1; i <= indent; i += 1) {
    result = result " "
  }
  return result
}

function pretty_print_list_contents( \
  id, indent, \
  result, i) \
{
  if (list_is_single(id) && memory_is_string(list_first(id)))
  {
    return ", " string_get(list_first(id))
  }
  else
  {
    result = ""

    i = id
    while (!list_is_empty(i)) {
      result = result "," NL pretty_print_with_indent(list_first(i), indent)
      i = list_rest(i)
    }

    return result
  }
}

function pretty_print_with_indent( \
  id, indent, \
  result, i, keys) \
{
  result = pretty_build_indent(indent)

  if (memory_is_string(id))
  {
    return result string_get(id)
  }
  else if (memory_is_list(id))
  {
    result = result "(list"

    result = result pretty_print_list_contents(id, indent + 2)

    result = result ")"
    return result
  }
  else if (memory_is_record(id))
  {
    result = result "(rec"

    record_keys(id, keys)
    for (i = 1; i <= keys["length"]; i += 1) {
      if (!(keys[i] ~ /^source/)) {
      result = result ";" NL \
        pretty_build_indent(indent + 2) keys[i] \
        pretty_print_list_contents(record_get(id, keys[i]), indent + 4)
      }
    }

    result = result ")"
    return result
  }
}
