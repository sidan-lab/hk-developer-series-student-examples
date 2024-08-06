use aiken/cbor
use aiken/dict.{Dict}
use aiken/hash.{Blake2b_256, Hash}
use aiken/transaction.{
  InlineDatum, Input, Output, Redeemer, ScriptPurpose, Spend, Transaction,
  placeholder,
}
use aiken/transaction/credential.{Address, ScriptCredential}
use aiken/transaction/value.{from_lovelace}
use sidan_placeholder/address.{mock_script_address}
use sidan_placeholder/builder.{
  complete, new_tx_tester, tx_in, tx_in_inline_datum,
}
use sidan_placeholder/key_hex.{mock_script_hash_hex}
use sidan_placeholder/output_reference.{mock_tx_hash, mock_utxo_ref}
use sidan_placeholder/outputs.{mock_script_output}
use sidan_placeholder/transaction.{add_input} as sidan_tx

type MockDatum {
  MockDatum
}

type MockRedeemer {
  MockRedeemer
}

// In unit test, we seldom use this field
fn get_mock_datums() -> Dict<Hash<Blake2b_256, Data>, Data> {
  let datum: Data = MockDatum
  dict.from_pairs([Pair(cbor.serialise(MockDatum), datum)])
}

// In unit test, we seldom use this field
fn get_mock_redeemers() -> Pairs<ScriptPurpose, Redeemer> {
  let redeemer: Redeemer = MockRedeemer
  [Pair(Spend(mock_utxo_ref(0, 0)), redeemer)]
}

/// Learning objective
/// 1. Learn about the concept of balance transaction: input value = output value + fee
/// 2. Learn about locking transaction needs a datum, and the importance of that
/// 3. Learn about inline datum vs datum hash in conceptual level
/// 4. Learn about the TxTester way of building script output for Transaction
fn mock_unlocking_tx() -> Transaction {
  let input =
    Input {
      output_reference: mock_utxo_ref(0, 0),
      output: Output {
        address: Address {
          payment_credential: ScriptCredential(mock_script_hash_hex(0)),
          stake_credential: None,
        },
        value: from_lovelace(10_000_000),
        datum: InlineDatum(MockDatum),
        reference_script: None,
      },
    }

  // In unit test, we seldom use this field
  Transaction {
    ..placeholder(),
    inputs: [input],
    redeemers: get_mock_redeemers(),
    datums: get_mock_datums(),
  }
}

// SIDAN tx builder

fn mock_locking_tx_sidan_tx_builder() -> Transaction {
  new_tx_tester()
    |> tx_in(
        True,
        mock_tx_hash(0),
        0,
        from_lovelace(10_000_000),
        mock_script_address(0, None),
      )
    |> tx_in_inline_datum(True, MockDatum)
    |> complete()
}

test m103_l4_sidan_tx_builder() {
  let tx_inputs = mock_unlocking_tx().inputs
  let sidan_tx_inputs = mock_locking_tx_sidan_tx_builder().inputs
  tx_inputs == sidan_tx_inputs
}

fn mock_locking_tx_sidan_tx() -> Transaction {
  let input =
    Input {
      output_reference: mock_utxo_ref(0, 0),
      output: mock_script_output(
        mock_script_address(0, None),
        from_lovelace(10_000_000),
        InlineDatum(MockDatum),
      ),
    }
  placeholder()
    |> add_input(True, input)
}

test m103_l4_sidan_tx() {
  let tx_inputs = mock_unlocking_tx().inputs
  let sidan_tx_inputs = mock_locking_tx_sidan_tx().inputs
  tx_inputs == sidan_tx_inputs
}
