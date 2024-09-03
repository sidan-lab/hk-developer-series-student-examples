use aiken/list
use aiken/transaction.{Input, Mint, OutputReference, ScriptContext, Transaction}
use aiken/transaction/value.{from_lovelace}
use mocktail.{complete, mocktail_tx, tx_in}
use mocktail/virgin_address.{mock_pub_key_address}
use mocktail/virgin_key_hex.{mock_policy_id}
use mocktail/virgin_output_reference.{mock_tx_hash, mock_utxo_ref}

/// Learning objecting
/// 1. Parameterizing script
/// 2. Familiar with property accessing for a type from transaction
/// 3. Familiar with control flow
validator(utxo: OutputReference) {
  fn always_succeed_minting_policy(_redeemer: Data, context: ScriptContext) {
    let inputs = context.transaction.inputs
    when list.find(inputs, fn(input) { input.output_reference == utxo }) is {
      Some(_) -> True
      _ -> False
    }
  }
}

test m202_l1_test_one_time_minting_policy() {
  let redeemer = Void

  let tx =
    mocktail_tx()
      |> tx_in(
          True,
          mock_tx_hash(0),
          0,
          from_lovelace(1_000_000),
          mock_pub_key_address(0, None),
        )
      |> complete()

  let context =
    ScriptContext { purpose: Mint(mock_policy_id(0)), transaction: tx }

  always_succeed_minting_policy(mock_utxo_ref(0, 0), redeemer, context)
}
