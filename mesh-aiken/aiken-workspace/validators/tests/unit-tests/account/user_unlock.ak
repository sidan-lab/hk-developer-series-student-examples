use account/account
use account/user_unlock
use aiken_game_account/placeholder.{
  mock_account_oracle_policy_id, mock_account_oracle_ref_input,
  mock_emergency_token, mock_operation_key, mock_user_vkey_hex, script_hash_5_1,
  script_hash_5_2,
}
use aiken_game_account/types.{AccountDatum, AccountRedeemer, AccountUserUnlock1}
use cardano/address.{Script}
use cardano/script_context.{ScriptContext, Withdrawing}
use cardano/transaction.{Transaction}
use mocktail.{
  add_reference_input, complete, mocktail_tx, required_signer_hash,
  script_withdrawal,
}
use mocktail/virgin_output_reference.{mock_utxo_ref}

fn user_unlock_ctx(tx: Transaction) -> ScriptContext {
  ScriptContext {
    transaction: tx,
    redeemer: Void,
    info: Withdrawing(Script(script_hash_5_1())),
  }
}

fn account_process(index: Int, tx: Transaction, redeemer: AccountRedeemer) {
  let input = mock_utxo_ref(0, index)
  account.account.spend(
    mock_user_vkey_hex(),
    script_hash_5_1(),
    script_hash_5_1(),
    script_hash_5_2(),
    mock_emergency_token(),
    Some(AccountDatum),
    redeemer,
    input,
    tx,
  )
}

type TestCase51 {
  is_owner_signed: Bool,
  is_operation_key_signed: Bool,
  is_withdrawal_script_present: Bool,
}

fn base_test_case_5_1() {
  TestCase51 {
    is_owner_signed: True,
    is_operation_key_signed: True,
    is_withdrawal_script_present: True,
  }
}

fn mock_test_case_5_1(test_case: TestCase51) {
  let TestCase51 {
    is_owner_signed,
    is_operation_key_signed,
    is_withdrawal_script_present,
  } = test_case

  mocktail_tx()
    |> required_signer_hash(is_owner_signed, mock_user_vkey_hex())
    |> required_signer_hash(is_operation_key_signed, mock_operation_key())
    |> script_withdrawal(is_withdrawal_script_present, script_hash_5_1(), 0)
    |> complete()
    |> add_reference_input(True, mock_account_oracle_ref_input())
}

test t5_1_success() {
  let redeemer = AccountUserUnlock1
  let tx = mock_test_case_5_1(base_test_case_5_1())
  account_process(1, tx, redeemer) && user_unlock.account_user_unlock.else(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    user_unlock_ctx(tx),
  )
}

test t5_1_success_mass() {
  let redeemer = AccountUserUnlock1
  // TODO: add tx in according to index
  let tx = mock_test_case_5_1(base_test_case_5_1())

  let unlock_process =
    fn(index: Int) { account_process(index, tx, redeemer) }
  unlock_process(0) && unlock_process(1) && unlock_process(2) && user_unlock.account_user_unlock.else(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    user_unlock_ctx(tx),
  )
}

test t5_1_fail_without_owner_signed() {
  let redeemer = AccountUserUnlock1
  let tx =
    mock_test_case_5_1(
      TestCase51 { ..base_test_case_5_1(), is_owner_signed: False },
    )
  account_process(1, tx, redeemer) && !user_unlock.account_user_unlock.else(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    user_unlock_ctx(tx),
  )
}

test t5_1_fail_without_app_signed() {
  let redeemer = AccountUserUnlock1
  let tx =
    mock_test_case_5_1(
      TestCase51 { ..base_test_case_5_1(), is_operation_key_signed: False },
    )
  account_process(1, tx, redeemer) && !user_unlock.account_user_unlock.else(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    user_unlock_ctx(tx),
  )
}

test t5_1_fail_without_withdrawal_script_present() {
  let redeemer = AccountUserUnlock1
  let tx =
    mock_test_case_5_1(
      TestCase51 { ..base_test_case_5_1(), is_withdrawal_script_present: False },
    )
  !account_process(1, tx, redeemer) && user_unlock.account_user_unlock.else(
    mock_account_oracle_policy_id(),
    mock_user_vkey_hex(),
    user_unlock_ctx(tx),
  )
}
