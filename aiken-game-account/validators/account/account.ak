use aiken/collection/pairs
use aiken/crypto.{ScriptHash}
use aiken_game_account/types.{
  AccountAppUnlock, AccountDatum, AccountEmergencyUnlock, AccountRedeemer,
  AccountUserUnlock1, AccountUserUnlock2,
}
use cardano/address.{Script}
use cardano/assets.{AssetName}
use cardano/transaction.{OutputReference, Transaction}
use vodka_extra_signatories.{key_signed}
use vodka_mints.{only_minted_token}

validator account(
  owner: ByteArray,
  user_unlock_1: ScriptHash,
  user_unlock_2: ScriptHash,
  app_unlock: ScriptHash,
  emergency_token: AssetName,
) {
  spend(
    _datum: Option<AccountDatum>,
    redeemer: AccountRedeemer,
    _input: OutputReference,
    tx: Transaction,
  ) {
    when redeemer is {
      AccountUserUnlock1 -> pairs.has_key(tx.withdrawals, Script(user_unlock_1))
      AccountUserUnlock2 -> pairs.has_key(tx.withdrawals, Script(user_unlock_2))
      AccountAppUnlock -> pairs.has_key(tx.withdrawals, Script(app_unlock))
      AccountEmergencyUnlock -> {
        let Transaction { extra_signatories, mint, .. } = tx
        let is_owner_signed = key_signed(extra_signatories, owner)
        let is_emergency_token_burnt =
          only_minted_token(mint, emergency_token, owner, -1)
        is_owner_signed? && is_emergency_token_burnt?
      }
    }
  }

  else(_) {
    fail
  }
}
