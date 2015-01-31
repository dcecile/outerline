@use("../src/utils")

function check_bold( \
  text \
  ) \
{
  return "\033[1m" text "\033[22m"
}

function check_ok( \
  text \
  ) \
{
  return "\033[32m" text "\033[39m"
}

function check_bad( \
  text \
  ) \
{
  return "\033[31m" text "\033[39m"
}

function check_matches( \
  unknown, valid \
  ) \
{
    if (unknown == valid) {
      printf("%s  ", check_ok("✔"))
    }
    else {
      printf("%s  ", check_bad("✖"))
      check_current_run_failed = true()
    }
}

function check_main( \
  \
  checks, failures, overall_fail, i, j) \
{
  # Initialize
  get_checks_data(checks)
  failures["length"] = 0

  # Do each module
  for (i = 1; i <= checks["length"]; i += 1) {
    printf("%s\n", check_bold(checks[i, "name"]))

    # Do each run
    for (j = 1; j <= checks[i, "length"]; j += 1) {
      printf("  %s ", check_bold(checks[i, j, "name"]))
      check_current_run_failed = false()
      run_check(i, j)
      printf("\n")

      # Keep track of run failures
      failures["length"] += 1
      failures[failures["length"]] = check_current_run_failed
    }
    printf("\n")
  }

  # Print out the run failures
  overall_fail = false()
  for (i = 1; i <= failures["length"]; i += 1) {
    if (failures[i]) {
      printf("%s  ", check_bad("✖"))
    }
    else {
      printf("%s  ", check_ok("✔"))
    }
    overall_fail = overall_fail || failures[i]
  }
  printf("\n")

  # Give a useful exit code
  if (overall_fail) {
    exit(1)
  }
  else {
    exit(0)
  }
}

BEGIN \
{
  check_current_run_failed = false()
  check_main()
}
