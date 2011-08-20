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
  exit_forced = 1
  exit(1)
}

BEGIN \
{
  exit_forced = 0
}

END \
{
  if (exit_forced)
  {
    exit(1)
  }
}
