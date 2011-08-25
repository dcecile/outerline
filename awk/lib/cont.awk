@use("./memory")

function cont_new0( \
  name \
  ) \
{
  return list_new1(record_new1("name", list_new1(string_new(name))))
}

function cont_new1( \
  name, key1, value1 \
  ) \
{
  return list_new1(record_new2("name", list_new1(string_new(name)),
    key1, value1))
}

function cont_new2( \
  name, key1, value1, key2, value2 \
  ) \
{
  return list_new1(record_new3("name", list_new1(string_new(name)),
    key1, value1, key2, value2))
}

function cont_new3( \
  name, key1, value1, key2, value2, key3, value3 \
  ) \
{
  return list_new1(record_new4("name", list_new1(string_new(name)),
    key1, value1, key2, value2, key3, value3))
}

function cont_new4( \
  name, key1, value1, key2, value2, key3, value3, key4, value4 \
  ) \
{
  return list_new1(record_new5("name", list_new1(string_new(name)),
    key1, value1, key2, value2, key3, value3, key4, value4))
}

function cont_new5( \
  name, key1, value1, key2, value2, key3, value3, key4, value4, key5, value5 \
  ) \
{
  return list_new1(record_new6("name", list_new1(string_new(name)),
    key1, value1, key2, value2, key3, value3, key4, value4, key5, value5))
}

function cont_fail( \
  message, cont \
  ) \
{
  fail(message)
}
