/// Learning Objective:
/// 1. Basic type signature of minting policy smart contract
/// 2. Basic type signature of spending validator smart contract
/// 3. Running test case with smart contracts (validator)

validator {
  fn always_succeed_minting_policy(_redeemer: Data, _context: Data) {
    True
  }
}

test m102_test_always_succeed_minting_policy() {
  let data = Void
  always_succeed_minting_policy(data, data)
}

validator {
  fn always_succeed_spending_validator(
    _datum: Data,
    _redeemer: Data,
    _context: Data,
  ) {
    True
  }
}

test m102_test_always_succeed_spending_validator() {
  let data = Void
  always_succeed_spending_validator(data, data, data)
}
