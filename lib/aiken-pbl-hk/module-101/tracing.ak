test m101_variable_tracing() {
  let is_this_true = False
  let is_this_false = True
  is_this_true? && is_this_false?
}

test m101_trace_message() {
  trace @"is_even"
  10 % 2 == 0
}

type MaybeSomething {
  Something { something: ByteArray }
  Nothing
}

fn maybe_something() -> MaybeSomething {
  Nothing
}

test m101_trace_message2() {
  trace @"hello"
  expect Something { something: _something }: MaybeSomething = maybe_something()
  trace @"world"
  True
}
