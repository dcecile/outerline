@use("./memory")

function cont_new0( \
  name \
  ) \
{
  return record_new1("name", list_new1(string_new(name)))
}

function cont_new1( \
  name, key1, value1 \
  ) \
{
  return record_new2("name", list_new1(string_new(name)),
    key1, value1)
}

function cont_new2( \
  name, key1, value1, key2, value2 \
  ) \
{
  return record_new3("name", list_new1(string_new(name)),
    key1, value1, key2, value2)
}

function cont_new3( \
  name, key1, value1, key2, value2, key3, value3 \
  ) \
{
  return record_new4("name", list_new1(string_new(name)),
    key1, value1, key2, value2, key3, value3)
}

function cont_new4( \
  name, key1, value1, key2, value2, key3, value3, key4, value4 \
  ) \
{
  return record_new5("name", list_new1(string_new(name)),
    key1, value1, key2, value2, key3, value3, key4, value4)
}

function cont_fail( \
  message, cont \
  ) \
{
  fail(message)
}
