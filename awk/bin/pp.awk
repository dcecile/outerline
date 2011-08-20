BEGIN \
{
  root()
}

function root( \
  \
  i, cache) \
{
  for (i in cache) {}
  for (i = 1; i < ARGC; i += 1) {
    pp(ARGV[i], cache)
  }
}

function pp( \
  file, cache, \
  found, line) \
{
  found = 0
  while ((getline line < file) > 0) {
    found = 1
    if (line ~ /^ *@use/) {
      use(file, line, cache)
    }
    else {
      print(line)
    }
  }

  if (!found) {
    print("Could not find file: " file) > "/dev/stderr"
    exit(1)
  }
  else {
    close(file)
  }
}

# Naively strip out single dots from a path (without converting double dots)
function abs_path( \
  path \
  ) \
{
  # Strip out /./ sequences
  while (sub(/\/\.\//, "/", path)) {}

  # Strip any leading ./
  sub(/^\.\//, "", path)
  return path
}

# Return the path, reduced by one level (or dot)
function dirname( \
  path \
  ) \
{
  # If there's no slash that the path can be trimmed to
  if (!sub(/\/[^\/]*$/, "", path)) {
    # Assume the current directory
    path = "."
  }
  return path
}

# Recursively include the file, if necessary
function use( \
  old_file, line, cache, \
  new_file) \
{
  # Strip out the macro, leaving only the module name
  sub(/^@use\("/, "", line)
  sub(/"\)$/, "", line)

  # Find the location of the new file 
  new_file = abs_path(dirname(old_file) "/" line) ".awk"

  # Recurse, if the module isn't already cached
  if (!(new_file in cache)) {
    cache[new_file] = 1
    pp(new_file, cache)
  }
}
