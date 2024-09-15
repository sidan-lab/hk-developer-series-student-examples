use aiken/collection/list
use cardano/assets.{PolicyId, zero}
use cardano/transaction.{OutputReference, Transaction}
use mocktail.{complete, mint, mocktail_tx, tx_in}
use mocktail/virgin_address.{mock_pub_key_address}
use mocktail/virgin_key_hash.{mock_policy_id}
use mocktail/virgin_output_reference.{mock_tx_hash, mock_utxo_ref}
use vodka_mints.{check_policy_only_burn}

pub type MyRedeemer {
  Mint
  Burn
}

/// A minting policy which parameter a OutputReference,
/// -> At minting, check whether the OutputReference exists in the inputs
/// -> At burning, it always allow the burning
validator one_time_minting_policy(utxo: OutputReference) {
  mint(redeemer: MyRedeemer, policy_id: PolicyId, tx: Transaction) {
    when redeemer is {
      Mint ->
        when
          list.find(tx.inputs, fn(input) { input.output_reference == utxo })
        is {
          Some(_) -> True
          None -> False
        }
      Burn -> check_policy_only_burn(tx.mint, policy_id)
    }
  }

  else(_) {
    fail
  }
}

test successful_mint() {
  let param = mock_utxo_ref(1, 0)
  let tx =
    mocktail_tx()
      |> tx_in(True, mock_tx_hash(1), 0, zero, mock_pub_key_address(0, None))
      |> complete()
  one_time_minting_policy.mint(param, Mint, mock_policy_id(0), tx)
}

test failed_mint_without_input() {
  let param = mock_utxo_ref(1, 0)
  let tx =
    mocktail_tx()
      |> tx_in(False, mock_tx_hash(1), 0, zero, mock_pub_key_address(0, None))
      |> complete()
  !one_time_minting_policy.mint(param, Mint, mock_policy_id(0), tx)
}

test successful_burn() {
  let tx =
    mocktail_tx()
      |> mint(True, -1, mock_policy_id(0), "")
      |> complete()
  one_time_minting_policy.mint(mock_utxo_ref(1, 0), Burn, mock_policy_id(0), tx)
}

test successful_burn_with_multiple() {
  let tx =
    mocktail_tx()
      |> mint(True, -1, mock_policy_id(0), "")
      |> mint(True, -1, mock_policy_id(0), "123")
      |> complete()
  one_time_minting_policy.mint(mock_utxo_ref(1, 0), Burn, mock_policy_id(0), tx)
}

test successful_burn_with_irrelevant_mint() {
  let tx =
    mocktail_tx()
      |> mint(True, -1, mock_policy_id(0), "")
      |> mint(True, 1, mock_policy_id(1), "")
      |> complete()
  one_time_minting_policy.mint(mock_utxo_ref(1, 0), Burn, mock_policy_id(0), tx)
}

test failed_burn() {
  let tx =
    mocktail_tx()
      |> mint(True, 1, mock_policy_id(0), "")
      |> mint(True, 1, mock_policy_id(1), "")
      |> complete()
  !one_time_minting_policy.mint(
    mock_utxo_ref(1, 0),
    Burn,
    mock_policy_id(0),
    tx,
  )
}
