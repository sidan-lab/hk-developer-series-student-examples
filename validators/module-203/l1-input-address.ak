use aiken/list
use aiken/transaction.{Input, ScriptContext, Spend, Transaction, find_input}
use aiken/transaction/credential.{Address}
use aiken/transaction/value.{from_lovelace}
use sidan_placeholder/address.{mock_pub_key_address, mock_script_address}
use sidan_placeholder/builder.{complete, new_tx_tester, tx_in}
use sidan_placeholder/output_reference.{mock_tx_hash, mock_utxo_ref}
use sidan_placeholder/outputs.{mock_pub_key_output}
use sidan_utils/inputs.{inputs_at}

fn filter_address_for_inputs(
  inputs: List<Input>,
  address: Address,
) -> List<Input> {
  list.filter(inputs, fn(input) { input.output.address == address })
}

test m203_l1_test_sidan_util_inputs_at() {
  let address = mock_pub_key_address(0, None)
  let inputs =
    [
      Input {
        output_reference: mock_utxo_ref(0, 0),
        output: mock_pub_key_output(address, from_lovelace(1_000_000)),
      },
      Input {
        output_reference: mock_utxo_ref(0, 0),
        output: mock_pub_key_output(
          mock_pub_key_address(1, None),
          from_lovelace(1_000_000),
        ),
      },
    ]
  expect [target_input, _other_input] = inputs
  expect [only_filterd_input] = filter_address_for_inputs(inputs, address)
  expect [sidan_filtered_input] = inputs_at(inputs, address)
  only_filterd_input == target_input && sidan_filtered_input == target_input
}

/// Learning objecting
/// 1. Learn how to find the input current validating from context.transaction
/// 2. Learn how to filter address for the inputs, with sidan util inputs_at
/// 3. Understand that in Cardano, seldomly there is only 1 input, i.e. script input + user input for covering some tx fee etc
validator {
  fn check_only_script_input_spending_validator(
    _datum: Data,
    _redeemer: Data,
    context: ScriptContext,
  ) {
    let ScriptContext { transaction, purpose } = context
    let Transaction { inputs, .. } = transaction

    expect Spend(utxo_ref) = purpose
    expect Some(own_input) = find_input(inputs, utxo_ref)
    when inputs_at(inputs, own_input.output.address) is {
      [_] -> True
      _ -> False
    }
  }
}

type TestCase {
  is_only_one_script_input: Bool,
}

fn mock_tx(test_case: TestCase) -> Transaction {
  let TestCase { is_only_one_script_input } = test_case

  new_tx_tester()
    |> tx_in(
        True,
        mock_tx_hash(0),
        0,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> tx_in(
        !is_only_one_script_input,
        mock_tx_hash(0),
        1,
        from_lovelace(1_000_000),
        mock_script_address(0, None),
      )
    |> complete()
}

test m203_l1_test_success() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(TestCase { is_only_one_script_input: True }),
    }
  check_only_script_input_spending_validator(Void, Void, context)
}

test m203_l1_test_fail_with_multiple_script_inputs() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(TestCase { is_only_one_script_input: False }),
    }
  !check_only_script_input_spending_validator(Void, Void, context)
}
