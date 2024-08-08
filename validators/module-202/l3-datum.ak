use aiken/transaction.{ScriptContext, Spend, placeholder}
use mocktail/virgin_output_reference.{mock_utxo_ref}

type Datum {
  Datum1 { secret: ByteArray }
  Datum2
}

type Redeemer {
  RedeemerWithMessage { message: ByteArray }
}

/// Learning objecting
/// 1. Get a sense of basic validation
/// 2. Can determine this is a dummy validator - not really guarding anything
/// 3. Can tell why the test cases can pass with placeholder transaction (nothing inside) 
validator {
  fn check_datum_spending_validator(
    datum: Datum,
    redeemer: Redeemer,
    _context: ScriptContext,
  ) {
    let RedeemerWithMessage { message } = redeemer
    when datum is {
      Datum1 { secret } -> message == secret
      Datum2 -> False
    }
  }
}

test m202_l3_test_success() {
  let redeemer = RedeemerWithMessage { message: "hello world" }

  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: placeholder(),
    }

  check_datum_spending_validator(
    Datum1 { secret: "hello world" },
    redeemer,
    context,
  )
}

test m202_l3_test_fail_with_incorrect_redeemer_message() {
  let redeemer = RedeemerWithMessage { message: "GM Cardano" }

  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: placeholder(),
    }

  !check_datum_spending_validator(
    Datum1 { secret: "hello world" },
    redeemer,
    context,
  )
}

test m202_l3_test_fail_with_fail_datum() {
  let redeemer = RedeemerWithMessage { message: "hello world" }

  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: placeholder(),
    }

  !check_datum_spending_validator(Datum2, redeemer, context)
}
