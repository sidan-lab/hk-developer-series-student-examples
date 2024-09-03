use aiken/transaction.{ScriptContext, Spend, placeholder}
use mocktail/virgin_output_reference.{mock_utxo_ref}

type Redeemer {
  SuccessRedeemer
  FailRedeemer
}

/// Learning objecting
/// 1. Familiar with control flow pattern of routing redeemer to different validation logics
validator {
  fn check_redeemer_spending_validator(
    _datum: Data,
    redeemer: Redeemer,
    _context: ScriptContext,
  ) {
    when redeemer is {
      SuccessRedeemer -> True
      FailRedeemer -> False
    }
  }
}

test m202_l2_test_success_redeemer() {
  let redeemer = SuccessRedeemer

  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: placeholder(),
    }

  check_redeemer_spending_validator(mock_utxo_ref(0, 0), redeemer, context)
}

test m202_l2_test_fail_redeemer() {
  let redeemer = FailRedeemer

  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: placeholder(),
    }

  !check_redeemer_spending_validator(mock_utxo_ref(0, 0), redeemer, context)
}
