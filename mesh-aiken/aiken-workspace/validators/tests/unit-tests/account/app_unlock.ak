use account/account
use account/app_unlock
use aiken_game_account/placeholder.{
  mock_account_address, mock_account_oracle_policy_id,
  mock_account_oracle_ref_input, mock_another_account_address,
  mock_emergency_token, mock_operation_key, mock_user_vkey_hex, script_hash_5_1,
  script_hash_5_2,
}
use aiken_game_account/types.{AccountAppUnlock, AccountDatum, AccountRedeemer}
use cardano/address.{Script}
use cardano/assets.{from_lovelace}
use cardano/transaction.{Transaction}
use mocktail.{
  MocktailTx, add_reference_input, complete, mocktail_tx, required_signer_hash,
  script_withdrawal, tx_in, tx_in_inline_datum, tx_out, tx_out_inline_datum,
}
use mocktail/virgin_output_reference.{mock_tx_hash, mock_utxo_ref}

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

type TestCase52 {
  is_operation_key_signed: Bool,
  is_value_resepnt_into_account: Bool,
  is_only_single_account: Bool,
  is_withdrawal_script_present: Bool,
}

fn base_test_case_5_2() {
  TestCase52 {
    is_operation_key_signed: True,
    is_value_resepnt_into_account: True,
    is_only_single_account: True,
    is_withdrawal_script_present: True,
  }
}

fn mock_test_case_5_2(number_of_inputs: Int, test_case: TestCase52) {
  let TestCase52 {
    is_operation_key_signed,
    is_value_resepnt_into_account,
    is_only_single_account,
    is_withdrawal_script_present,
  } = test_case

  let add_account_input =
    fn(tx_tester: MocktailTx, index: Int) {
      tx_tester
        |> tx_in(
            index < number_of_inputs,
            mock_tx_hash(0),
            index + 1,
            from_lovelace(5_000_000),
            mock_account_address(),
          )
        |> tx_in_inline_datum(index < number_of_inputs, AccountDatum)
    }

  mocktail_tx()
    |> add_account_input(0)
    |> add_account_input(1)
    |> add_account_input(2)
    |> add_account_input(3)
    |> add_account_input(4)
    |> add_account_input(5)
    |> add_account_input(6)
    |> add_account_input(7)
    |> add_account_input(8)
    |> add_account_input(9)
    |> add_account_input(10)
    |> tx_in(
        !is_only_single_account,
        mock_tx_hash(1),
        0,
        from_lovelace(5_000_000),
        mock_another_account_address(),
      )
    |> tx_in_inline_datum(!is_only_single_account, AccountDatum)
    |> tx_out(
        True,
        mock_account_address(),
        from_lovelace(5_000_000 * ( number_of_inputs - 1 )),
      )
    |> tx_out_inline_datum(True, AccountDatum)
    |> tx_out(
        is_value_resepnt_into_account,
        mock_account_address(),
        from_lovelace(5_000_000 * ( number_of_inputs - 1 )),
      )
    |> tx_out_inline_datum(is_value_resepnt_into_account, AccountDatum)
    |> required_signer_hash(is_operation_key_signed, mock_operation_key())
    |> script_withdrawal(is_withdrawal_script_present, script_hash_5_2(), 0)
    |> complete()
    |> add_reference_input(True, mock_account_oracle_ref_input())
}

test t5_2_success() {
  let tx = mock_test_case_5_2(10, base_test_case_5_2())
  account_process(0, tx, AccountAppUnlock) && app_unlock.account_app_unlock.withdraw(
    mock_account_oracle_policy_id(),
    Void,
    Script(script_hash_5_2()),
    tx,
  )
}

test t5_2_failed_without_operation_key_signed() {
  let tx =
    mock_test_case_5_2(
      10,
      TestCase52 { ..base_test_case_5_2(), is_operation_key_signed: False },
    )
  account_process(0, tx, AccountAppUnlock) && !app_unlock.account_app_unlock.withdraw(
    mock_account_oracle_policy_id(),
    Void,
    Script(script_hash_5_2()),
    tx,
  )
}

test t5_2_failed_without_value_resepnt_into_account() {
  let tx =
    mock_test_case_5_2(
      10,
      TestCase52 {
        ..base_test_case_5_2(),
        is_value_resepnt_into_account: False,
      },
    )
  account_process(0, tx, AccountAppUnlock) && !app_unlock.account_app_unlock.withdraw(
    mock_account_oracle_policy_id(),
    Void,
    Script(script_hash_5_2()),
    tx,
  )
}

test t5_2_failed_with_other_account_unlock_attempt() {
  let tx =
    mock_test_case_5_2(
      10,
      TestCase52 { ..base_test_case_5_2(), is_only_single_account: False },
    )
  account_process(0, tx, AccountAppUnlock) && !app_unlock.account_app_unlock.withdraw(
    mock_account_oracle_policy_id(),
    Void,
    Script(script_hash_5_2()),
    tx,
  )
}

test t5_2_failed_without_withdrawal_script_present() {
  let tx =
    mock_test_case_5_2(
      10,
      TestCase52 { ..base_test_case_5_2(), is_withdrawal_script_present: False },
    )
  !account_process(0, tx, AccountAppUnlock) && app_unlock.account_app_unlock.withdraw(
    mock_account_oracle_policy_id(),
    Void,
    Script(script_hash_5_2()),
    tx,
  )
}
