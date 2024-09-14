use aiken/collection/list
use cardano/assets.{from_lovelace}
use cardano/transaction.{OutputReference, Transaction}
use mocktail.{complete, mocktail_tx, tx_in, tx_out}
use mocktail/virgin_address.{mock_pub_key_address, mock_script_address}
use mocktail/virgin_output_reference.{mock_tx_hash, mock_utxo_ref}

validator check_inputs_outputs {
  spend(
    _datum: Option<Data>,
    _redeemer: Data,
    _input: OutputReference,
    tx: Transaction,
  ) {
    let Transaction { inputs, outputs, .. } = tx
    let only_one_input = list.length(inputs) == 1
    let only_one_output = list.length(outputs) == 1

    only_one_input? && only_one_output?
  }

  else(_) {
    fail
  }
}

type TestCase {
  no_input: Bool,
  no_output: Bool,
  more_than_one_input: Bool,
  more_than_one_output: Bool,
}

fn get_transaction(test_case: TestCase) -> Transaction {
  mocktail_tx()
    |> tx_in(
        !test_case.no_input,
        mock_tx_hash(0),
        0,
        from_lovelace(100),
        mock_script_address(0, None),
      )
    |> tx_in(
        test_case.more_than_one_input,
        mock_tx_hash(0),
        0,
        from_lovelace(100),
        mock_script_address(0, None),
      )
    |> tx_in(
        test_case.more_than_one_input,
        mock_tx_hash(0),
        0,
        from_lovelace(100),
        mock_script_address(0, None),
      )
    |> tx_out(
        !test_case.no_output,
        mock_pub_key_address(0, None),
        from_lovelace(100),
      )
    |> tx_out(
        test_case.more_than_one_output,
        mock_pub_key_address(0, None),
        from_lovelace(100),
      )
    |> tx_out(
        test_case.more_than_one_output,
        mock_pub_key_address(0, None),
        from_lovelace(100),
      )
    |> complete()
}

test test_check_inputs_outputs() {
  let tx =
    get_transaction(
      TestCase {
        no_input: False,
        no_output: False,
        more_than_one_input: False,
        more_than_one_output: False,
      },
    )
  check_inputs_outputs.spend(None, "", mock_utxo_ref(0, 0), tx)
}

test test_check_inputs_outputs_fail_1() {
  let tx =
    get_transaction(
      TestCase {
        no_input: True,
        no_output: False,
        more_than_one_input: False,
        more_than_one_output: False,
      },
    )
  !check_inputs_outputs.spend(None, "", mock_utxo_ref(0, 0), tx)
}

test test_check_inputs_outputs_fail_2() {
  let tx =
    get_transaction(
      TestCase {
        no_input: False,
        no_output: True,
        more_than_one_input: False,
        more_than_one_output: False,
      },
    )
  !check_inputs_outputs.spend(None, "", mock_utxo_ref(0, 0), tx)
}

test test_check_inputs_outputs_fail_3() {
  let tx =
    get_transaction(
      TestCase {
        no_input: False,
        no_output: False,
        more_than_one_input: True,
        more_than_one_output: False,
      },
    )
  !check_inputs_outputs.spend(None, "", mock_utxo_ref(0, 0), tx)
}

test test_check_inputs_outputs_fail_4() {
  let tx =
    get_transaction(
      TestCase {
        no_input: False,
        no_output: False,
        more_than_one_input: False,
        more_than_one_output: True,
      },
    )
  !check_inputs_outputs.spend(None, "", mock_utxo_ref(0, 0), tx)
}
