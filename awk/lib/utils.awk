function true( \
  \
  ) \
{
  return 1
}

function false( \
  \
  ) \
{
  return 0
}

function clear( \
  array, \
  i) \
{
  for (i in array) {
    delete array[i]
  }
}

function fail( \
  message \
  ) \
{
  print(message) > "/dev/stderr"
  exit(1)
}

BEGIN \
{
  NL = "\n"
}
