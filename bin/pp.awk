BEGIN \
{
  root()
}

function root( \
  \
  i, cache, checks) \
{
  for (i in cache) {}
  for (i = 1; i < ARGC; i += 1) {
    pp(abs_path(ARGV[i]), cache, checks)
  }
  add_check_hooks(checks)
}

function pp( \
  file, cache, checks, \
  found, line) \
{
  found = 0
  while ((getline line < file) > 0) {
    found = 1
    if (sub(/^ *@use/, "", line)) {
      use(file, line, cache, checks)
    }
    else if (sub(/^ *@check/, "", line)) {
      check(file, line, checks)
    }
    else {
      print(line)
    }
  }

  if (!found) {
    fail("Could not find file: " file)
  }
  else {
    close(file)
  }
}

# Recursively include the file, if necessary
function use( \
  old_file, line, cache, checks, \
  new_file) \
{
  # Strip out the macro, leaving only the module name
  if (!sub(/^\("/, "", line) || !sub(/"\)$/, "", line)) {
    fail("@use parse error: " old_file)
  }

  # Find the location of the new file
  new_file = abs_path(dirname(old_file) "/" line) ".awk"

  # Recurse, if the module isn't already cached
  if (!(new_file in cache)) {
    cache[new_file] = 1
    pp(new_file, cache, checks)
  }
}

function check_module( \
  file, checks, \
  id) \
{
  if (!("length" in checks)) {
    checks["length"] = 1
  }
  else {
    checks["length"] += 1
  }
  id = checks["length"]
  checks[file] = id
  checks[id, "name"] = file
  checks[id, "length"] = 0
}

function check( \
  file, line, checks, \
  module_id, run_id) \
{
  # Parse out the name
  if (!sub(/^\("/, "", line) || !sub(/", \\$/, "", line)) {
    fail("@check parse error: " file)
  }

  # Get or add the module
  if (!(file in checks)) {
    check_module(file, checks)
  }
  module_id = checks[file]

  # Add the run
  checks[module_id, "length"] += 1
  run_id = checks[module_id, "length"]
  checks[module_id, run_id, "name"] = line

  # Open a function for this run
  print("# " line)
  print("function check_run_" module_id "_" run_id "( \\")
}

function add_check_hooks( \
  checks, \
  i, j) \
{
  # If @check wasn't used, there should be no hooks
  if (!("length" in checks)) {
    return
  }

  # Set up the data
  print("")
  print("# Auto-generated")
  print("function get_checks_data( \\")
  print("  checks \\")
  print("  ) \\")
  print("{")
  print("  checks[\"length\"] = " checks["length"])
  for (i = 1; i <= checks["length"]; i += 1) {
    print("  checks[" i ", \"name\"] = \"" checks[i, "name"] "\"")
    print("  checks[" i ", \"length\"] = " checks[i, "length"])
    for (j = 1; j <= checks[i, "length"]; j += 1) {
      print("  checks[" i ", " j ", \"name\"] = \"" checks[i, j, "name"] "\"")
    }
  }
  print("}")

  # Set up the dispatcher
  print("")
  print("# Auto-generated")
  print("function run_check( \\")
  print("  module_id, run_id \\")
  print("  ) \\")
  print("{")
  for (i = 1; i <= checks["length"]; i += 1) {
    for (j = 1; j <= checks[i, "length"]; j += 1) {
      print("  if (module_id == " i " && run_id == " j ") {")
      print("    check_run_" i "_" j "()")
      print("  }")
    }
  }
  print("}")
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

function fail( \
  message \
  ) {
  print(message) > "/dev/stderr"
  exit(1)
}
