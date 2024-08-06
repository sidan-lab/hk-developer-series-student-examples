use aiken/transaction.{Transaction, placeholder}
use aiken/transaction/value.{from_asset, from_minted_value, to_minted_value}
use sidan_placeholder/builder.{complete, mint, new_tx_tester}
use sidan_placeholder/transaction.{add_mint} as sidan_tx

fn mock_policy() {
  "test policy"
}

fn mock_token_name() {
  "test token name"
}

/// Learning objective
/// 1. Understand that for testing purpose, we dont have to do balance tx
/// 2. Learn about the TxTester way of building mint for Transaction
fn mock_minting_tx() -> Transaction {
  Transaction {
    ..placeholder(),
    mint: from_asset(mock_policy(), mock_token_name(), 1) |> to_minted_value(),
  }
}

test m103_l2_mock_minting_tx() {
  let tx = mock_minting_tx()
  from_minted_value(tx.mint) == from_asset(mock_policy(), mock_token_name(), 1)
}

// SIDAN tx builder

fn mock_minting_tx_sidan_tx_builder() -> Transaction {
  new_tx_tester()
    |> mint(True, 1, mock_policy(), mock_token_name())
    |> complete()
}

test m103_l2_sidan_tx_builder() {
  mock_minting_tx() == mock_minting_tx_sidan_tx_builder()
}

fn mock_minting_tx_sidan_tx() -> Transaction {
  placeholder()
    |> add_mint(True, from_asset(mock_policy(), mock_token_name(), 1))
}

test m103_l2_sidan_tx() {
  mock_minting_tx() == mock_minting_tx_sidan_tx()
}
