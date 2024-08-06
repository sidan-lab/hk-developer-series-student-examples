use aiken/transaction.{ScriptContext, Spend, Transaction}
use aiken/transaction/value.{from_lovelace}
use sidan_placeholder/address.{mock_pub_key_address, mock_script_address}
use sidan_placeholder/builder.{complete, new_tx_tester, tx_in, tx_out}
use sidan_placeholder/output_reference.{mock_tx_hash, mock_utxo_ref}

/// Learning objecting
/// 1. Familar with accessing transaction information - inputs & outputs
/// 2. Can interpret the single input validation means in current transaction, there is only script input
/// 3. Familiar with the control flow pattern matching with number of items in a list
validator {
  fn check_only_script_input_spending_validator(
    _datum: Data,
    _redeemer: Data,
    context: ScriptContext,
  ) {
    let Transaction { inputs, outputs, .. } = context.transaction
    when (inputs, outputs) is {
      ([_], [_]) -> True
      _ -> False
    }
  }
}

type TestCase {
  is_input_present: Bool,
  is_single_input: Bool,
  is_output_present: Bool,
  is_single_output: Bool,
}

fn mock_tx(test_case: TestCase) -> Transaction {
  let TestCase {
    is_input_present,
    is_single_input,
    is_output_present,
    is_single_output,
  } = test_case

  new_tx_tester()
    |> tx_in(
        is_input_present,
        mock_tx_hash(0),
        0,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> tx_in(
        !is_single_input,
        mock_tx_hash(0),
        1,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> tx_in(
        !is_single_input,
        mock_tx_hash(0),
        2,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> tx_out(
        is_output_present,
        mock_pub_key_address(0, None),
        from_lovelace(1_000_000),
      )
    |> tx_out(
        !is_single_output,
        mock_pub_key_address(0, None),
        from_lovelace(1_000_000),
      )
    |> tx_out(
        !is_single_output,
        mock_pub_key_address(0, None),
        from_lovelace(1_000_000),
      )
    |> complete()
}

test m202_l7_test_success() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(
        TestCase {
          is_input_present: True,
          is_single_input: True,
          is_output_present: True,
          is_single_output: True,
        },
      ),
    }

  check_only_script_input_spending_validator(Void, Void, context)
}

test m202_l7_test_fail_with_no_input() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(
        TestCase {
          is_input_present: False,
          is_single_input: True,
          is_output_present: True,
          is_single_output: True,
        },
      ),
    }

  !check_only_script_input_spending_validator(Void, Void, context)
}

test m202_l7_test_fail_with_multiple_input() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(
        TestCase {
          is_input_present: True,
          is_single_input: False,
          is_output_present: True,
          is_single_output: True,
        },
      ),
    }

  !check_only_script_input_spending_validator(Void, Void, context)
}

test m202_l7_test_fail_with_no_output() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(
        TestCase {
          is_input_present: True,
          is_single_input: True,
          is_output_present: False,
          is_single_output: True,
        },
      ),
    }

  !check_only_script_input_spending_validator(Void, Void, context)
}

test m202_l7_test_fail_with_multiple_output() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(
        TestCase {
          is_input_present: True,
          is_single_input: True,
          is_output_present: True,
          is_single_output: False,
        },
      ),
    }

  !check_only_script_input_spending_validator(Void, Void, context)
}
