use aiken/transaction.{Mint, ScriptContext, Spend, placeholder}
use mocktail/virgin_output_reference.{mock_utxo_ref}

/// Learning Objective:
/// 1. Basic type signature of minting policy smart contract
/// 2. Basic type signature of spending validator smart contract
/// 3. Basic idea of context
/// 4. Running test case with smart contracts (validator)
validator {
  fn always_succeed_minting_policy(_redeemer: Data, context: ScriptContext) {
    expect Mint(_) = context.purpose
    True
  }
}

test m102_test_always_succeed_minting_policy() {
  let data = Void
  let context = ScriptContext { purpose: Mint(#""), transaction: placeholder() }
  always_succeed_minting_policy(data, context)
}

validator {
  fn always_succeed_spending_validator(
    _datum: Data,
    _redeemer: Data,
    context: ScriptContext,
  ) {
    expect Spend(_) = context.purpose
    True
  }
}

test m102_test_always_succeed_spending_validator() {
  let data = Void
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: placeholder(),
    }
  always_succeed_spending_validator(data, data, context)
}

test m102_fail_test_always_succeed_spending_validator() {
  let data = Void
  let context = ScriptContext { purpose: Mint(#""), transaction: placeholder() }
  always_succeed_spending_validator(data, data, context)
  // !always_succeed_spending_validator(data, data, context) // Why both lines fail?
}
