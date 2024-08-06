use aiken/transaction.{Transaction, placeholder}
use aiken/transaction/value.{from_asset, from_minted_value, to_minted_value}
use sidan_placeholder/builder.{complete, mint, new_tx_tester}
use sidan_placeholder/key_hex.{mock_policy_id}
use sidan_placeholder/transaction.{add_mint} as sidan_tx

fn mock_token_name() {
  "test token name"
}

/// Learning objective
/// 1. Understand that for testing purpose, we dont have to do balance tx
/// 2. Learn about sidan_placeholder: mock_policy_id
/// 3. Understand what's the difference between different key hex utils, e.g. mock_policy_id vs mock_pub_key_hex
/// 4. Learn about the TxTester way of building mint for Transaction
fn mock_minting_tx() -> Transaction {
  Transaction {
    ..placeholder(),
    mint: from_asset(mock_policy_id(0), mock_token_name(), 1)
      |> to_minted_value(),
  }
}

test m103_l2_mock_minting_tx() {
  let tx = mock_minting_tx()
  from_minted_value(tx.mint) == from_asset(
    mock_policy_id(0),
    mock_token_name(),
    1,
  )
}

// SIDAN tx builder

fn mock_minting_tx_sidan_tx_builder() -> Transaction {
  new_tx_tester()
    |> mint(True, 1, mock_policy_id(0), mock_token_name())
    |> complete()
}

test m103_l2_sidan_tx_builder() {
  mock_minting_tx() == mock_minting_tx_sidan_tx_builder()
}

fn mock_minting_tx_sidan_tx() -> Transaction {
  placeholder()
    |> add_mint(True, from_asset(mock_policy_id(0), mock_token_name(), 1))
}

test m103_l2_sidan_tx() {
  mock_minting_tx() == mock_minting_tx_sidan_tx()
}
