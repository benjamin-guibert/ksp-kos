global function prompt {
  parameter key.
  parameter validate.
  parameter defaultValue is "".

  print key + "? [" + defaultValue + "]".
  local input is "".
  local valid is false.
  local value is defaultValue.

  until valid {
    local inputChar is terminal:input:getchar().

    if inputChar = terminal:input:enter {
      if input set value to input.
      set valid to validate(value).
      if not valid {
        set input to "".
        print "'" + value + "' is an invalid value.".
      }
    }.
    else set input to input + inputChar.
  }

  return value.
}

global function promptBool {
  parameter question.
  parameter defaultValue is false.

  print question + " (" + (choose "Y" if defaultValue else "y") + "/"+ (choose "n" if defaultValue else "N") +")?".
  until false {
    local inputChar is terminal:input:getchar().

    if inputChar = terminal:input:enter return defaultValue.
    else if inputChar:tolower() = "y" return true.
    else if inputChar:tolower() = "n" return false.
  }
}
