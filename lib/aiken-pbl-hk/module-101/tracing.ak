test m101_variable_tracing() {
  let is_this_true = False
  let is_this_false = True
  is_this_true? && is_this_false?
}

test m101_trace_message() {
  trace @"is_even"
  10 % 2 == 0
}

fn maybe_something() -> Option<ByteArray> {
  None
}

test m101_trace_message2() {
  trace @"hello"
  expect Some(_something): Option<ByteArray> = maybe_something()
  trace @"world"
  True
}
