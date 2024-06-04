test bool_true_type() {
  True
}

test bool_false_type() {
  !False
}

test bool_equal_operator() {
  True == True
}

test bool_not_equal_operator() {
  True != False
}

test bool_and_operator() {
  let result = and {
      True == True,
      False == False,
    }
  result
}

test bool_and_operator_short_form() {
  let result = True == True && False == False
  result
}

test bool_or_operator() {
  let result = or {
      True == True,
      False == True,
    }
  result
}

test bool_or_operator_short_form() {
  let result = True == True || False == True
  result
}

test bool_nested_operator() {
  let result = and {
      True,
      False,
      or {
        True,
        False,
      },
    }
  !result
}

test bool_tracing() {
  let is_this_true = False
  let is_this_false = True
  is_this_true? && is_this_false?
}
