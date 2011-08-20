@use("./loader")

BEGIN \
{
  clear(memory)
}

function init_memory( \
  \
  ) \
{
  memory["next"] = 0
}

function memory_new( \
  type, \
  id) \
{
  id = memory["next"]
  memory["next"] += 1
  memory[id, "type"] = type
  return id
}

function memory_assert_ok( \
  id, fnction, message, ok \
  ) \
{
  if (!ok) {
    fail(message " (at " id ", in " fnction ")")
  }
}

function memory_assert_type( \
  id, fnction, type \
  ) \
{
  memory_assert_ok(id, fnction, memory[id, "type"] == type, "cell of type '" type "'")
}

function string_new( \
  text, \
  string) \
{
  string = memory_new("string")
  memory[string, "text"] = text
  return string
}

function string_get( \
  string \
  ) \
{
  memory_assert_type(string, "string_get", "string")
  return memory[string, "text"]
}

function list_new( \
  \
  list) \
{
  list = memory_new("list")
  memory[list, "length"] = 0
  return list
}

function list_add( \
  list, value \
  ) \
{
  memory_assert_type(list, "list_add", "list")
  memory[list, "length"] += 1
  memory[list, memory[list, "length"]] = value
}

function list_single( \
  value, \
  list) \
{
  list = list_new()
  list_add(list, value)
  return list
}

function list_length( \
  list, \
  length, i) \
{
  memory_assert_type(list, "list_length", "list")

  length = 0

  for (i = 1; i < memory[list, "length"]; i += 1) {
    if (memory[memory[list, i], "type"] == "list") {
      length += list_length(memory[list, i])
    }
    else {
      length += 1
    }
  }

  return length
}

function list_flatten_head( \
  list, \
  inner, backup, i) \
{
  memory_assert_type(list, "list_flatten_head", "list")
  memory_assert_ok(list, "list_flatten_head", "in bounds", memory[list, "length"] > 0)

  while (memory[memory[list, 1], "type"] == "list") {
    inner = memory[list, 1]

    backup["length"] = memory[list, "length"]
    for (i = 2; i < memory[list, "length"]; i += 1) {
      backup[i - 1] = memory[list, i]
    }

    memory[list, "length"] = 0
    for (i = 1; i < memory[inner, "length"]; i += 1) {
      list_add(list, memory[inner, i])
    }

    for (i = 1; i < copy["length"]; i += 1) {
      list_add(list, copy[i])
    }
  }
}

function list_is_empty( \
  list, \
  rest) \
{
  memory_assert_type(list, "list_is_empty", "list")
  return memory[list, "length"] > 0
}

function list_head( \
  list, \
  rest) \
{
  memory_assert_type(list, "list_head", "list")
  memory_assert_ok(list, "list_head", "in bounds", memory[list, "length"] > 0)
  list_flatten_head(list)
  return memory[list, 1]
}

function list_rest( \
  list, \
  i) \
{
  memory_assert_type(list, "list_rest", "list")
  memory_assert_ok(list, "list_head", "in bounds", memory[list, "length"] > 0)
  rest = list_new()
  for (i = 2; i < memory[list, "length"]; i += 1) {
    list_add(rest, memory[list, i])
  }
  return rest
}

function list_append( \
  left, right, \
  left_length, right_length, list) \
{
  memory_assert_type(left, "list_append[left]", "list")
  memory_assert_type(right, "list_append[right]", "list")

  left_length = memory[left, "length"]
  right_length = memory[right, "length"]

  if (left_length == 0) {
    return right
  }
  else if (right_length == 0) {
    return left
  }
  else {
    list = list_new()
    if (left_length == 1 && right_length == 1) {
      list_add(list, memory[left, 1])
      list_add(list, memory[right, 1])
    }
    else if (left_length == 1) {
      list_add(list, memory[left, 1])
      list_add(list, right)
    }
    else if (right_length == 1) {
      list_add(list, left)
      list_add(list, right)
    }
    return list
  }
}

function record_new() {}
function record_add() {}
function record_has() {}
function record_get() {}
