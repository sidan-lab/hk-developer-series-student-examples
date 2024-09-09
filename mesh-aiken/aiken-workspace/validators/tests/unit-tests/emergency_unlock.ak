use aiken_game_account/placeholder.{
  mock_account_oracle_policy_id, mock_account_oracle_ref_input,
  mock_emergency_token, mock_emergency_unlock_address, mock_operation_key,
  mock_user_vkey_hex,
}
use aiken_game_account/types.{EmergencyUnlockDatum}
use cardano/assets.{from_asset}
use cardano/transaction.{Transaction}
use emergency_unlock
use mocktail.{
  add_reference_input, complete, invalid_before, mint, mocktail_tx,
  required_signer_hash, tx_in, tx_in_inline_datum,
}
use mocktail/virgin_output_reference.{mock_tx_hash, mock_utxo_ref}

type TestCase31 {
  is_owner_signed: Bool,
  is_admin_signed: Bool,
  is_emergency_token_exist: Bool,
  is_emergency_token_burnt: Bool,
  is_current_time_after_1_days: Bool,
  is_current_time_after_2_days: Bool,
  is_datum_valid: Bool,
}

fn mock_tx(test_case: TestCase31) -> Transaction {
  let TestCase31 {
    is_owner_signed,
    is_admin_signed,
    is_emergency_token_exist,
    is_emergency_token_burnt,
    is_current_time_after_1_days,
    is_current_time_after_2_days,
    is_datum_valid,
  } = test_case
  mocktail_tx()
    |> tx_in(
        is_emergency_token_exist,
        mock_tx_hash(0),
        0,
        from_asset(mock_emergency_token(), mock_user_vkey_hex(), 1),
        mock_emergency_unlock_address(),
      )
    |> tx_in_inline_datum(
        is_emergency_token_exist && is_datum_valid,
        EmergencyUnlockDatum { minted_at: 100 },
      )
    |> tx_in_inline_datum(is_emergency_token_exist && !is_datum_valid, Void)
    |> mint(
        is_emergency_token_burnt,
        -1,
        mock_emergency_token(),
        mock_user_vkey_hex(),
      )
    |> invalid_before(is_current_time_after_1_days, 100 + 86_400_002)
    |> invalid_before(is_current_time_after_2_days, 100 + 172_800_002)
    |> required_signer_hash(is_owner_signed, mock_user_vkey_hex())
    |> required_signer_hash(is_admin_signed, mock_operation_key())
    |> complete()
    |> add_reference_input(True, mock_account_oracle_ref_input())
}

test t3_1_success_user_unlock() {
  let datum: Data = EmergencyUnlockDatum { minted_at: 100 }
  let tx =
    mock_tx(
      TestCase31 {
        is_owner_signed: True,
        is_admin_signed: False,
        is_emergency_token_exist: True,
        is_emergency_token_burnt: True,
        is_current_time_after_1_days: True,
        is_current_time_after_2_days: False,
        is_datum_valid: True,
      },
    )

  emergency_unlock.emergency_unlock.spend(
    mock_account_oracle_policy_id(),
    Some(datum),
    Void,
    mock_utxo_ref(0, 0),
    tx,
  )
}

test t3_1_success_admin_unlock_at_expire() {
  let datum: Data = EmergencyUnlockDatum { minted_at: 100 }
  let tx =
    mock_tx(
      TestCase31 {
        is_owner_signed: False,
        is_admin_signed: True,
        is_emergency_token_exist: True,
        is_emergency_token_burnt: True,
        is_current_time_after_1_days: True,
        is_current_time_after_2_days: True,
        is_datum_valid: True,
      },
    )

  emergency_unlock.emergency_unlock.spend(
    mock_account_oracle_policy_id(),
    Some(datum),
    Void,
    mock_utxo_ref(0, 0),
    tx,
  )
}

test t3_1_success_admin_unlock_when_token_not_exist() {
  let datum: Data = EmergencyUnlockDatum { minted_at: 100 }
  let tx =
    mock_tx(
      TestCase31 {
        is_owner_signed: False,
        is_admin_signed: True,
        is_emergency_token_exist: False,
        is_emergency_token_burnt: True,
        is_current_time_after_1_days: False,
        is_current_time_after_2_days: False,
        is_datum_valid: True,
      },
    )

  emergency_unlock.emergency_unlock.spend(
    mock_account_oracle_policy_id(),
    Some(datum),
    Void,
    mock_utxo_ref(0, 0),
    tx,
  )
}

test t3_1_success_admin_unlock_for_invalid_datum() {
  let tx =
    mock_tx(
      TestCase31 {
        is_owner_signed: False,
        is_admin_signed: True,
        is_emergency_token_exist: False,
        is_emergency_token_burnt: True,
        is_current_time_after_1_days: False,
        is_current_time_after_2_days: False,
        is_datum_valid: False,
      },
    )

  emergency_unlock.emergency_unlock.spend(
    mock_account_oracle_policy_id(),
    None,
    Void,
    mock_utxo_ref(0, 0),
    tx,
  )
}

test t3_1_fail_user_unlock_without_signature() {
  let tx =
    mock_tx(
      TestCase31 {
        is_owner_signed: False,
        is_admin_signed: False,
        is_emergency_token_exist: True,
        is_emergency_token_burnt: True,
        is_current_time_after_1_days: True,
        is_current_time_after_2_days: False,
        is_datum_valid: True,
      },
    )

  !emergency_unlock.emergency_unlock.spend(
    mock_account_oracle_policy_id(),
    None,
    Void,
    mock_utxo_ref(0, 0),
    tx,
  )
}

test t3_1_fail_user_unlock_without_emergency_token() {
  let tx =
    mock_tx(
      TestCase31 {
        is_owner_signed: True,
        is_admin_signed: False,
        is_emergency_token_exist: False,
        is_emergency_token_burnt: True,
        is_current_time_after_1_days: True,
        is_current_time_after_2_days: False,
        is_datum_valid: True,
      },
    )

  !emergency_unlock.emergency_unlock.spend(
    mock_account_oracle_policy_id(),
    None,
    Void,
    mock_utxo_ref(0, 0),
    tx,
  )
}

test t3_1_fail_user_unlock_without_emergency_token_burnt() {
  let tx =
    mock_tx(
      TestCase31 {
        is_owner_signed: True,
        is_admin_signed: False,
        is_emergency_token_exist: True,
        is_emergency_token_burnt: False,
        is_current_time_after_1_days: True,
        is_current_time_after_2_days: False,
        is_datum_valid: True,
      },
    )

  !emergency_unlock.emergency_unlock.spend(
    mock_account_oracle_policy_id(),
    None,
    Void,
    mock_utxo_ref(0, 0),
    tx,
  )
}

test t3_1_fail_user_unlock_without_one_day() {
  let tx =
    mock_tx(
      TestCase31 {
        is_owner_signed: True,
        is_admin_signed: False,
        is_emergency_token_exist: True,
        is_emergency_token_burnt: True,
        is_current_time_after_1_days: False,
        is_current_time_after_2_days: False,
        is_datum_valid: True,
      },
    )

  !emergency_unlock.emergency_unlock.spend(
    mock_account_oracle_policy_id(),
    None,
    Void,
    mock_utxo_ref(0, 0),
    tx,
  )
}

test t3_1_fail_user_unlock_after_two_day() {
  let tx =
    mock_tx(
      TestCase31 {
        is_owner_signed: True,
        is_admin_signed: False,
        is_emergency_token_exist: True,
        is_emergency_token_burnt: True,
        is_current_time_after_1_days: True,
        is_current_time_after_2_days: True,
        is_datum_valid: True,
      },
    )

  !emergency_unlock.emergency_unlock.spend(
    mock_account_oracle_policy_id(),
    None,
    Void,
    mock_utxo_ref(0, 0),
    tx,
  )
}

test t3_1_fail_user_unlock_without_valid_datum() {
  let tx =
    mock_tx(
      TestCase31 {
        is_owner_signed: True,
        is_admin_signed: False,
        is_emergency_token_exist: True,
        is_emergency_token_burnt: True,
        is_current_time_after_1_days: True,
        is_current_time_after_2_days: False,
        is_datum_valid: False,
      },
    )

  !emergency_unlock.emergency_unlock.spend(
    mock_account_oracle_policy_id(),
    None,
    Void,
    mock_utxo_ref(0, 0),
    tx,
  )
}
