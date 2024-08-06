use aiken/transaction.{Transaction, placeholder}
use aiken/transaction/value.{from_asset, from_minted_value, to_minted_value}

/// Learning objective
/// 1. Understand that for testing purpose, we dont have to do balance tx
fn mock_minting_tx() -> Transaction {
  Transaction {
    ..placeholder(),
    mint: from_asset("test policy", "test token name", 1) |> to_minted_value(),
  }
}

test m103_l2_mock_minting_tx() {
  let tx = mock_minting_tx()
  from_minted_value(tx.mint) == from_asset("test policy", "test token name", 1)
}
