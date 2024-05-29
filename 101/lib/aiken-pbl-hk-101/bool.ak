test true_type() {
  True
}

test false_type() {
  !False
}

test equal_operator() {
  True == True
}

test not_equal_operator() {
  True != False
}

test and_operator() {
  let result = and {
      True == True,
      False == False,
    }
  result
}

test and_operator_short_form() {
  let result = True == True && False == False
  result
}

test or_operator() {
  let result = or {
      True == True,
      False == True,
    }
  result
}

test or_operator_short_form() {
  let result = True == True || False == True
  result
}

test nested_operator() {
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
