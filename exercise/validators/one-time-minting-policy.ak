use cardano/assets.{PolicyId}
use cardano/transaction.{Transaction}

/// A minting policy which parameter a OutputReference,
/// -> At minting, check whether the OutputReference exists in the inputs
/// -> At burning, it always allow the burning
validator one_time_minting_policy {
  mint(redeemer: Data, policy_id: PolicyId, tx: Transaction) {
    todo
  }

  else(_) {
    fail
  }
}
