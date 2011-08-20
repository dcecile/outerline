@use("./utils")

BEGIN \
{
  clear(memory)
  init_memory()
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

function memory_is_string( \
  id \
  ) \
{
  return memory[id, "type"] == "string"
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

function list_new0( \
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

function list_new1( \
  value1, \
  list) \
{
  list = list_new0()
  list_add(list, value1)
  return list
}

function list_length( \
  list, \
  len, i) \
{
  memory_assert_type(list, "list_length", "list")

  len = 0

  for (i = 1; i <= memory[list, "length"]; i += 1) {
    if (memory[memory[list, i], "type"] == "list") {
      len += list_length(memory[list, i])
    }
    else {
      len += 1
    }
  }

  return len
}

function list_flatten_head( \
  list, \
  inner, backup, i) \
{
  memory_assert_type(list, "list_flatten_head", "list")
  memory_assert_ok(list, "list_flatten_head", "in bounds", memory[list, "length"] > 0)

  while (memory[memory[list, 1], "type"] == "list") {
    inner = memory[list, 1]

    backup["length"] = memory[list, "length"] - 1
    for (i = 2; i <= memory[list, "length"]; i += 1) {
      backup[i - 1] = memory[list, i]
    }

    memory[list, "length"] = 0
    for (i = 1; i <= memory[inner, "length"]; i += 1) {
      list_add(list, memory[inner, i])
    }

    for (i = 1; i <= backup["length"]; i += 1) {
      list_add(list, backup[i])
    }
  }
}

function list_is_empty( \
  list \
  ) \
{
  memory_assert_type(list, "list_is_empty", "list")
  return memory[list, "length"] == 0
}

function list_first( \
  list \
  ) \
{
  memory_assert_type(list, "list_first", "list")
  memory_assert_ok(list, "list_first", "in bounds", memory[list, "length"] > 0)
  list_flatten_head(list)
  return memory[list, 1]
}

function list_rest( \
  list, \
  rest, i) \
{
  memory_assert_type(list, "list_rest", "list")
  memory_assert_ok(list, "list_first", "in bounds", memory[list, "length"] > 0)
  rest = list_new0()
  for (i = 2; i <= memory[list, "length"]; i += 1) {
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
    list = list_new0()
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

function record_new0( \
  \
  record) \
{
  record = memory_new("record")
  memory[record, "keys", "length"] = 0
  return record
}

function record_add( \
  record, key, value \
  ) \
{
  memory_assert_type(record, "record_add", "record")
  memory_assert_type(value, "record_add", "list")
  memory[record, "keys", "length"] += 1
  memory[record, "keys", memory[record, "keys", "length"]] = key
  memory[record, "data", key] = value
}

function record_new1( \
  key1, value1, \
  record) \
{
  record = record_new0()
  record_add(record, key1, value1)
  return record
}

function record_new2( \
  key1, value1, key2, value2, \
  record) \
{
  record = record_new1(key1, value1)
  record_add(record, key2, value2)
  return record
}

function record_new3( \
  key1, value1, key2, value2, key3, value3, \
  record) \
{
  record = record_new2(key1, value1, key2, value2)
  record_add(record, key3, value3)
  return record
}

function record_new4( \
  key1, value1, key2, value2, key3, value3, key4, value4, \
  record) \
{
  record = record_new3(key1, value1, key2, value2, key3, value3)
  record_add(record, key4, value4)
  return record
}

function record_new5( \
  key1, value1, key2, value2, key3, value3, key4, value4, key5, value5, \
  record) \
{
  record = record_new4(key1, value1, key2, value2, key3, value3, key4, value4)
  record_add(record, key5, value5)
  return record
}

function record_has( \
  record, key \
  ) \
{
  memory_assert_type(record, "record_has", "record")
  return (record SUBSEP "data" SUBSEP key) in memory
}

function record_get( \
  record, key \
  ) \
{
  memory_assert_type(record, "record_get", "record")
  memory_assert_ok(record, "record_get", "valid property", record_has(record, key))
  return memory[record, "data", key]
}

function variant_get( \
  record \
  ) \
{
  return string_get(list_first(record_get(record, "type")))
}
