@use("./loader")

function init_memory( \
  \
  ) \
{
  memory["next"] = 0
}

function clear( \
  array, \
  i) \
{
  for (i in array) {
    delete array[i]
  }
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
  id, message, ok \
  ) \
{
  if (!ok) {
    fail()
  }
}

function memory_assert_type( \
  id, type \
  ) \
{
  memory_assert_ok()
}

function string_new( \
  text, \
  string) \
{
  string = memory_new("string")
  memory[string, "text"] = text
  return string
}

function string_get() {}

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
  memory_assert_type(list, "list")
  memory[list, "length"] += 1
  memory[list, memory[list, "length"]] = value
}

function list_get( \
  list, i \
  ) \
{
  memory_assert_ok(list, "list access in bounds", i <= memory[list, "length"])
  memory_assert_type(list, "list")
}

function record_new() {}
function record_add() {}
function record_has() {}
function record_get() {}

BEGIN {
  clear(memory)
  print(init_memory())
}
