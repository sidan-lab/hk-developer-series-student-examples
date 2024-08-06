use aiken/transaction.{NoDatum, Output, Transaction, placeholder}
use aiken/transaction/credential.{Address, ScriptCredential}
use aiken/transaction/value.{from_lovelace}
use sidan_placeholder/address.{mock_script_address}
use sidan_placeholder/builder.{complete, new_tx_tester, tx_out}
use sidan_placeholder/key_hex.{mock_script_hash_hex}
use sidan_placeholder/outputs.{mock_pub_key_output}
use sidan_placeholder/transaction.{add_output} as sidan_tx

/// Learning objective
/// 1. Learn about the concept of balance transaction: input value = output value + fee
/// 2. Familiar with the structure of an input
/// 3. Familiar with the structure of an output
/// 4. Familiar with how to construct Cardano native value, lovelace and token
/// 5. Learn about sidan_placeholder: mock_pub_key_address, mock_pub_key_output
/// 6. Learn about the TxTester way of building input and output for Transaction
fn mock_locking_tx() -> Transaction {
  let output =
    Output {
      address: Address {
        payment_credential: ScriptCredential(mock_script_hash_hex(0)),
        stake_credential: None,
      },
      value: from_lovelace(10_000_000),
      reference_script: None,
      datum: NoDatum,
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
    |> complete()
}

test m103_l3_sidan_tx_builder() {
  let tx = mock_locking_tx()
  let sidan_tx = mock_locking_tx_sidan_tx_builder()
  tx == sidan_tx
}

fn mock_locking_tx_sidan_tx() -> Transaction {
  let output =
    mock_pub_key_output(mock_script_address(0, None), from_lovelace(10_000_000))
  placeholder()
    |> add_output(True, output)
}

test m103_l3_sidan_tx() {
  let tx = mock_locking_tx()
  let sidan_tx = mock_locking_tx_sidan_tx()
  tx == sidan_tx
}
