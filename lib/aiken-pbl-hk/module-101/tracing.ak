fn is_even(n: Int) -> Bool {
  trace @"is_even"
  n % 2 == 0
}

fn is_odd(n: Int) -> Bool {
  trace @"is_odd"
  n % 2 != 0
}

test m101_bool_tracing() {
  let is_this_true = False
  let is_this_false = True
  is_this_true? && is_this_false?
}
