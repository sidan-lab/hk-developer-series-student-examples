use aiken/transaction.{
  InlineDatum, Input, ScriptContext, Spend, Transaction, find_input,
}
use aiken/transaction/value.{from_lovelace}
use sidan_placeholder/address.{mock_pub_key_address}
use sidan_placeholder/builder.{
  complete, new_tx_tester, tx_in, tx_in_inline_datum,
}
use sidan_placeholder/output_reference.{mock_tx_hash, mock_utxo_ref}

type Datum {
  Datum1 { secret: ByteArray }
  Datum2
}

type Redeemer {
  RedeemerWithMessage { message: ByteArray }
}

/// Learning objecting
/// 1. Understand the reason behind directly using datum producing in type signature input is unpopular in Cardano development 
///    - since it can be accessed from context.transaction
/// 2. Learn about how to cast the Data type into the customized data type
validator {
  fn check_script_input_value_spending_validator(
    _datum: Datum,
    redeemer: Redeemer,
    context: ScriptContext,
  ) {
    let ScriptContext { transaction, purpose } = context
    let Transaction { inputs, .. } = transaction
    expect Spend(utxo_ref) = purpose
    expect Some(own_input) = find_input(inputs, utxo_ref)

    expect InlineDatum(raw_datum) = own_input.output.datum
    expect input_datum: Datum = raw_datum
    let RedeemerWithMessage { message } = redeemer
    when input_datum is {
      Datum1 { secret } -> message == secret
      Datum2 -> False
    }
  }
}

type TestCase {
  is_datum_correct: Bool,
  is_secret_provided: Bool,
}

fn mock_tx(test_case: TestCase) -> Transaction {
  let TestCase { is_datum_correct, is_secret_provided } = test_case
  let secret =
    if is_secret_provided {
      "hello world"
    } else {
      "GM Cardano"
    }
  let datum =
    if is_datum_correct {
      Datum1 { secret }
    } else {
      Datum2
    }

  new_tx_tester()
    |> tx_in(
        True,
        mock_tx_hash(0),
        0,
        from_lovelace(1_000_000),
        mock_pub_key_address(0, None),
      )
    |> tx_in_inline_datum(True, datum)
    |> complete()
}

test m203_l3_test_success() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(
        TestCase { is_datum_correct: True, is_secret_provided: True },
      ),
    }
  check_script_input_value_spending_validator(
    Datum1 { secret: "hello world" },
    RedeemerWithMessage { message: "hello world" },
    context,
  )
}

test m203_l3_test_fail_with_wrong_secret() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(
        TestCase { is_datum_correct: True, is_secret_provided: False },
      ),
    }
  !check_script_input_value_spending_validator(
    Datum1 { secret: "hello world" },
    RedeemerWithMessage { message: "hello world" },
    context,
  )
}

test m203_l3_test_fail_with_wrong_datum() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(
        TestCase { is_datum_correct: False, is_secret_provided: True },
      ),
    }
  !check_script_input_value_spending_validator(
    Datum1 { secret: "hello world" },
    RedeemerWithMessage { message: "hello world" },
    context,
  )
}
