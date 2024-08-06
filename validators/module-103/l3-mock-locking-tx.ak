use aiken/transaction.{InlineDatum, Output, Transaction, placeholder}
use aiken/transaction/credential.{Address, ScriptCredential}
use aiken/transaction/value.{from_lovelace}
use sidan_placeholder/address.{mock_script_address}
use sidan_placeholder/builder.{
  complete, new_tx_tester, tx_out, tx_out_inline_datum,
}
use sidan_placeholder/key_hex.{mock_script_hash_hex}
use sidan_placeholder/outputs.{mock_script_output}
use sidan_placeholder/transaction.{add_output} as sidan_tx

type MockDatum {
  MockDatum
}

/// Learning objective
/// 1. Learn about the concept of balance transaction: input value = output value + fee
/// 2. Learn about locking transaction needs a datum, and the importance of that
/// 3. Learn about inline datum vs datum hash in conceptual level
/// 4. Learn about sidan_placeholder: mock_script_hash_hex, mock_script_address, mock_script_output
/// 5. Learn about the TxTester way of building script output for Transaction
fn mock_locking_tx() -> Transaction {
  let output =
    Output {
      address: Address {
        payment_credential: ScriptCredential(mock_script_hash_hex(0)),
        stake_credential: None,
      },
      value: from_lovelace(10_000_000),
      datum: InlineDatum(MockDatum),
      reference_script: None,
    }
  Transaction { ..placeholder(), outputs: [output] }
}

test m103_l3_sidan_mock_address() {
  let tx = mock_locking_tx()
  expect [output] = tx.outputs
  output.address == mock_script_address(0, None)
}

// SIDAN tx builder

fn mock_locking_tx_sidan_tx_builder() -> Transaction {
  new_tx_tester()
    |> tx_out(True, mock_script_address(0, None), from_lovelace(10_000_000))
    |> tx_out_inline_datum(True, MockDatum)
    |> complete()
}

test m103_l3_sidan_tx_builder() {
  let tx = mock_locking_tx()
  let sidan_tx = mock_locking_tx_sidan_tx_builder()
  tx == sidan_tx
}

fn mock_locking_tx_sidan_tx() -> Transaction {
  let output =
    mock_script_output(
      mock_script_address(0, None),
      from_lovelace(10_000_000),
      InlineDatum(MockDatum),
    )
  placeholder()
    |> add_output(True, output)
}

test m103_l3_sidan_tx() {
  let tx = mock_locking_tx()
  let sidan_tx = mock_locking_tx_sidan_tx()
  tx == sidan_tx
}
