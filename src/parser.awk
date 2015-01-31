@use("./utils")
@use("./memory")
@use("./expr")
@use("./pretty")

function parse_push_call( \
  stack, text, \
  position_begin)
{
  stack["size"] += 1

  stack[stack["size"], "arguments"] = list_new0()
  stack[stack["size"], "next_argument"] = false()
}

function parse_pop_call( \
  stack \
  ) \
{
  stack["size"] -= 1
}

function parse_eat_whitespace( \
  text)
{
  sub(/^[ \n]+/, "", text)
  return text
}

function parse_begin_call( \
  stack, text \
  ) \
{
  if (stack[stack["size"], "next_argument"]) {
    fail("unexpected call")
  }

  text = parse_eat_whitespace(text)
  parse_push_call(stack, text)

  return text
}

function parse_end_call( \
  stack, text, \
  arguments, old_statements)
{
  # Finish the current argument
  text = parse_end_argument(stack, text)

  # The parent argument is finished
  stack[stack["size"] - 1, "next_argument"] = \
    expr_new_call(stack[stack["size"], "arguments"])

  # The call is finished
  parse_pop_call(stack)

  return text
}

function parse_end_file( \
  stack, text, \
  arguments)
{
  if (stack["size"] > 1)
  {
    fail("unexpected end - missing something")
  }

  # Finish the current argument
  text = parse_end_argument(stack, text)

  # Done everything
  return stack[stack["size"], "arguments"]
}

function parse_end_argument( \
  stack, text, \
  all_arguments, next_argument)
{
  all_arguments = stack[stack["size"], "arguments"]
  next_argument = stack[stack["size"], "next_argument"]
  
  if (!next_argument) {
    # No explicit arguments
    next_argument = \
      expr_new_string(list_new1(string_new("")))
  }

  # Add this argument
  list_add( \
    all_arguments,
    next_argument)
  stack[stack["size"], "next_argument"] = false()

  text = parse_eat_whitespace(text)

  return text
}

function parse_literal( \
  stack, text, \
  position_begin, position_end, string_length, string)
{
  if (stack[stack["size"], "next_argument"]) {
    fail("unexpected literal")
  }

  # Try to find the whitespace+terminal following this string
  string_length = match(text, / *([(){},;#\n]|$)/) - 1

  if (string_length <= 0) {
    fail("invalid literal")
  }

  # Split out the string
  literal = substr(text, 1, string_length)

  text = string_length == length(text) \
    ? "" \
    : substr(text, string_length + 1)

  # This (simple) argument is finished
  stack[stack["size"], "next_argument"] = \
    expr_new_string(list_new1(string_new(literal)))

  return parse_eat_whitespace(text)
}

function parse_text( \
  text, \
  stack) \
{
  # Eat whitespace
  text = parse_eat_whitespace(text)

  # Set up root stack
  stack["size"] = 0
  parse_push_call(stack, text)

  while (true()) {
    # EOF
    if (text ~ /^$/) {
      return parse_end_file(stack, text)
    }

    # Begin call
    else if (sub(/^\(/, "", text)) {
      text = parse_begin_call(stack, text)
    }

    # End call
    else if (sub(/^\)/, "", text)) {
      text = parse_end_call(stack, text)
    }

    # Comma
    else if (sub(/^,/, "", text)) {
      text = parse_end_argument(stack, text)
    }

    # Semicolon

    # Begin interpolation

    # End interpolation

    # Literal string (find and extract)
    else {
      text = parse_literal(stack, text)
    }
  }
}
