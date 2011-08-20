@use("./utils")
@use("./memory")
@use("./expr")

function load_lines( \
  lines, \
  i, j, k, mapping, id, text, items, call_list) \
{
  # For each string
  if (lines["length"] < 1) {
    fail("not enough lines to load (at start)")
  }
  i = 1
  while (length(lines[i]) > 0) {

    # Find the ID and the text
    j = index(lines[i], " ")
    if (j == 0) {
      fail("invalid string entry")
    }
    id = substr(lines[i], 1, j - 1)
    text = substr(lines[i], j + 1)

    # Add the string to the mapping
    mapping[id] = expr_new_string( \
      list_new1(string_new(text)))
    i += 1
  }

  # Skip over the blank line separator
  i += 1

  # For each call
  if (i > lines["length"]) {
    fail("not enough lines to load (after strings)")
  }
  while (i <= lines["length"]) {
    # Split up the ID and each call item
    j = split(lines[i], items, " ")
    id = items[1]

    # Create the call list out of (non-list) subitems
    call_list = list_new0()
    for (k = 2; k <= j; k += 1) {
      list_add(call_list, mapping[items[k]])
    }

    # Add the call to the mapping
    mapping[id] = expr_new_call( \
      call_list)
    i += 1
  }

  # Return the last call as the root of the expression
  return list_new1(mapping[id])
}

function load_text( \
  text, \
  len, lines) \
{
  len = split(text, lines, NL)
  lines["length"] = len
  return load_lines(lines)
}
