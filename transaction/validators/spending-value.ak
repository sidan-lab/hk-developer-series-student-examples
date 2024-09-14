use cardano/assets.{add, from_lovelace}
use cardano/transaction.{OutputReference, Transaction}
use mocktail.{complete, mocktail_tx, tx_in, tx_out}
use mocktail/virgin_address.{mock_pub_key_address, mock_script_address}
use mocktail/virgin_output_reference.{mock_tx_hash, mock_utxo_ref}
use vodka_value.{value_geq}

validator check_value {
  spend(
    _datum: Option<Data>,
    _redeemer: Data,
    _input: OutputReference,
    tx: Transaction,
  ) {
    let Transaction { inputs, outputs, .. } = tx

    when (inputs, outputs) is {
      ([only_input], [only_output]) -> {
        let input_value = only_input.output.value
        let output_value = only_output.value
        let is_output_less_than_input = value_geq(input_value, output_value)
        is_output_less_than_input?
      }
      _ -> False
    }
  }

  else(_) {
    fail
  }
}

type TestCase {
  is_other_token_fulfill_output_leq_input: Bool,
}

fn get_transaction(test_case: TestCase) -> Transaction {
  let input_value = from_lovelace(100)
  let output_value =
    if test_case.is_other_token_fulfill_output_leq_input {
      from_lovelace(99)
    } else {
      from_lovelace(99) |> add("another token policy", "another token name", 1)
    }

  mocktail_tx()
    |> tx_in(True, mock_tx_hash(0), 0, input_value, mock_script_address(0, None))
    |> tx_out(True, mock_pub_key_address(0, None), output_value)
    |> complete()
}

test test_check_value() {
  let tx =
    get_transaction(TestCase { is_other_token_fulfill_output_leq_input: True })
  check_value.spend(None, "", mock_utxo_ref(0, 0), tx)
}

test test_check_value_fail() {
  let tx =
    get_transaction(TestCase { is_other_token_fulfill_output_leq_input: False })
  !check_value.spend(None, "", mock_utxo_ref(0, 0), tx)
}
