use aiken/transaction.{ScriptContext, Spend, Transaction}
use aiken/transaction/value.{from_lovelace}
use sidan_placeholder/address.{mock_pub_key_address}
use sidan_placeholder/builder.{complete, new_tx_tester, ref_tx_in}
use sidan_placeholder/output_reference.{mock_tx_hash, mock_utxo_ref}

/// Learning objecting
/// 1. Accessing transaction information
/// 2. Distinguish control flow with when {} is {} and expect()
/// 3. Learn building reference input with SIDAN tx builder
/// 4. Learn about comprehensive test case with SIDAN tx builder pattern
validator {
  fn check_reference_inputs_spending_validator(
    _datum: Data,
    _redeemer: Data,
    context: ScriptContext,
  ) {
    let Transaction { reference_inputs, .. } = context.transaction
    when reference_inputs is {
      [_] -> True
      _ -> False
    }
  }
}

type TestCase {
  is_ref_input_present: Bool,
  is_multiple_ref_inputs: Bool,
}

fn mock_tx(test_case: TestCase) -> Transaction {
  let TestCase { is_ref_input_present, is_multiple_ref_inputs } = test_case
  new_tx_tester()
    |> ref_tx_in(
        is_ref_input_present,
        mock_tx_hash(0),
        1,
        from_lovelace(1_000_000),
        mock_pub_key_address(0, None),
      )
    |> ref_tx_in(
        is_multiple_ref_inputs,
        mock_tx_hash(0),
        2,
        from_lovelace(1_000_000),
        mock_pub_key_address(0, None),
      )
    |> ref_tx_in(
        is_multiple_ref_inputs,
        mock_tx_hash(0),
        3,
        from_lovelace(1_000_000),
        mock_pub_key_address(0, None),
      )
    |> complete()
}

test m202_l4_test_success() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(
        TestCase { is_ref_input_present: True, is_multiple_ref_inputs: False },
      ),
    }

  check_reference_inputs_spending_validator(Void, Void, context)
}

test m202_l4_test_fail_with_no_ref_input() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(
        TestCase { is_ref_input_present: False, is_multiple_ref_inputs: False },
      ),
    }

  !check_reference_inputs_spending_validator(Void, Void, context)
}

test m202_l4_test_fail_with_multiple_ref_input() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(
        TestCase { is_ref_input_present: False, is_multiple_ref_inputs: True },
      ),
    }

  !check_reference_inputs_spending_validator(Void, Void, context)
}
