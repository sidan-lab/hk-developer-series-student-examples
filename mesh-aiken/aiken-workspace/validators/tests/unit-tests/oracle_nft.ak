use aiken_game_account/types.{RBurn, RMint}
use cardano/assets.{PolicyId, from_lovelace}
use cardano/transaction.{placeholder}
use mocktail.{complete, mint, mocktail_tx, tx_in}
use mocktail/virgin_address.{mock_pub_key_address}
use mocktail/virgin_key_hash.{mock_policy_id}
use mocktail/virgin_output_reference.{mock_tx_hash, mock_utxo_ref}
use oracle_nft

test success_mint() {
  let redeemer = RMint
  let input_utxo = mock_utxo_ref(0, 1)
  let policy_id: PolicyId =
    #"1c1b7afe8affbee1505cf3ec5a58bd2734d4ffdfcc9b9f059625bd76"

  let tx =
    mocktail_tx()
      |> mint(True, 1, policy_id, "")
      |> tx_in(
          True,
          mock_tx_hash(0),
          1,
          from_lovelace(1000000),
          mock_pub_key_address(0, None),
        )
      |> complete()

  oracle_nft.oracle_nft.mint(input_utxo, redeemer, policy_id, tx)
}

test fail_mint_no_utxo_ref_supply() {
  let redeemer = RMint
  let policy_id = mock_policy_id(0)

  !oracle_nft.oracle_nft.mint(
    mock_utxo_ref(0, 0),
    redeemer,
    policy_id,
    placeholder,
  )
}

test success_burn() {
  let redeemer = RBurn
  let policy_id = mock_policy_id(0)

  let tx =
    mocktail_tx()
      |> mint(True, -1, policy_id, "")
      |> complete()

  oracle_nft.oracle_nft.mint(mock_utxo_ref(0, 0), redeemer, policy_id, tx)
}

test success_burn_with_other_minting() {
  let redeemer = RBurn
  let policy_id = mock_policy_id(0)

  let tx =
    mocktail_tx()
      |> mint(True, -1, policy_id, "")
      |> mint(True, -1, mock_policy_id(1), "")
      |> complete()
  oracle_nft.oracle_nft.mint(mock_utxo_ref(0, 0), redeemer, policy_id, tx)
}

test fail_burn_with_mint() {
  let redeemer = RBurn
  let policy_id = mock_policy_id(0)

  let tx =
    mocktail_tx()
      |> mint(True, 1, policy_id, "")
      |> complete()

  !oracle_nft.oracle_nft.mint(mock_utxo_ref(0, 0), redeemer, policy_id, tx)
}

test fail_burn_with_mix() {
  let redeemer = RBurn
  let policy_id = mock_policy_id(0)

  let tx =
    mocktail_tx()
      |> mint(True, -1, policy_id, "")
      |> mint(True, 1, policy_id, "1")
      |> complete()

  !oracle_nft.oracle_nft.mint(mock_utxo_ref(0, 0), redeemer, policy_id, tx)
}
