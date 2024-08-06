use aiken/transaction.{Input, NoDatum, Output, Transaction, placeholder}
use aiken/transaction/credential.{Address, VerificationKeyCredential}
use aiken/transaction/value.{from_asset, from_lovelace}
use sidan_placeholder/address.{mock_pub_key_address}
use sidan_placeholder/key_hex.{mock_pub_key_hex}
use sidan_placeholder/output_reference.{mock_utxo_ref}
use sidan_placeholder/outputs.{mock_pub_key_output}

/// Learning objective
/// 1. Learn about the concept of balance transaction: input value = output value + fee
/// 2. Familiar with the structure of an input
/// 3. Familiar with the structure of an output
/// 4. Familiar with how to construct Cardano native value, lovelace and token
/// 5. Learn about sidan_placeholder: mock_pub_key_address, mock_pub_key_output
fn mock_spending_tx() -> Transaction {
  let input =
    Input {
      output_reference: mock_utxo_ref(0, 0),
      output: Output {
        address: Address {
          payment_credential: VerificationKeyCredential(mock_pub_key_hex(0)),
          stake_credential: None,
        },
        value: from_asset("", "", 10_000_000),
        reference_script: None,
        datum: NoDatum,
      },
    }
  let output =
    Output {
      address: Address {
        payment_credential: VerificationKeyCredential(mock_pub_key_hex(1)),
        stake_credential: None,
      },
      value: from_lovelace(9_000_000),
      reference_script: None,
      datum: NoDatum,
    }
  let fee = from_lovelace(1_000_000)
  Transaction { ..placeholder(), inputs: [input], outputs: [output], fee: fee }
}

test m103_l1_sidan_mock_address() {
  let tx = mock_spending_tx()
  expect [input] = tx.inputs
  let address = input.output.address
  address == mock_pub_key_address(0, None)
}

test m103_l1_sidan_mock_output() {
  let tx = mock_spending_tx()
  expect [input] = tx.inputs
  input.output == mock_pub_key_output(
    mock_pub_key_address(0, None),
    from_lovelace(10_000_000),
  )
}

test m103_l1_sidan_mock_output_2() {
  let tx = mock_spending_tx()
  expect [output] = tx.outputs
  output == mock_pub_key_output(
    mock_pub_key_address(1, None),
    from_lovelace(9_000_000),
  )
}
