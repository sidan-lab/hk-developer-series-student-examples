use aiken_game_account/placeholder.{
  mock_emergency_action_output, mock_emergency_token,
  mock_emergency_unlock_address, mock_user_vkey_hex,
} as game_placeholder
use aiken_game_account/types.{EBurn, EMint}
use cardano/assets.{add, from_asset}
use cardano/transaction.{Transaction, placeholder}
use emergency_token
use mocktail/virgin_validity_range.{mock_interval}

type TestCase {
  is_owner_signed: Bool,
  is_emergency_token_name_correct: Bool,
  is_datum_correct: Bool,
  is_time_valid: Bool,
}

fn base_test_case() -> TestCase {
  TestCase {
    is_owner_signed: True,
    is_emergency_token_name_correct: True,
    is_datum_correct: True,
    is_time_valid: True,
  }
}

fn mint_test_case(test_case: TestCase) {
  let TestCase {
    is_owner_signed,
    is_emergency_token_name_correct,
    is_datum_correct,
    is_time_valid,
  } = test_case
  let extra_signatories =
    if is_owner_signed {
      [mock_user_vkey_hex()]
    } else {
      []
    }
  let mint =
    if is_emergency_token_name_correct {
      from_asset(mock_emergency_token(), mock_user_vkey_hex(), 1)
    } else {
      from_asset(mock_emergency_token(), "Incorrect name", 1)
    }
  let validity_range =
    mock_interval(
      None,
      Some(
        if is_time_valid {
          99
        } else {
          101
        },
      ),
    )
  let outputs =
    [
      mock_emergency_action_output(
        if is_datum_correct {
          100
        } else {
          50
        },
        mock_user_vkey_hex(),
      ),
    ]
  Transaction {
    ..placeholder,
    extra_signatories: extra_signatories,
    mint: mint,
    validity_range: validity_range,
    outputs: outputs,
  }
}

test t2_1_success_mint() {
  let redeemer = EMint { minter: mock_user_vkey_hex() }
  let policy_id = mock_emergency_token()

  let tx = mint_test_case(base_test_case())
  emergency_token.emergency_token.mint(
    mock_emergency_unlock_address(),
    redeemer,
    policy_id,
    tx,
  )
}

test t2_1_fail_mint_without_owner_signature() {
  let redeemer = EMint { minter: mock_user_vkey_hex() }
  let policy_id = mock_emergency_token()

  let tx =
    mint_test_case(TestCase { ..base_test_case(), is_owner_signed: False })
  !emergency_token.emergency_token.mint(
    mock_emergency_unlock_address(),
    redeemer,
    policy_id,
    tx,
  )
}

test t2_1_fail_mint_with_incorrect_emergency_token_name() {
  let redeemer = EMint { minter: mock_user_vkey_hex() }
  let policy_id = mock_emergency_token()

  let tx =
    mint_test_case(
      TestCase { ..base_test_case(), is_emergency_token_name_correct: False },
    )
  !emergency_token.emergency_token.mint(
    mock_emergency_unlock_address(),
    redeemer,
    policy_id,
    tx,
  )
}

test t2_1_fail_mint_without_correct_datum() {
  let redeemer = EMint { minter: mock_user_vkey_hex() }
  let policy_id = mock_emergency_token()

  let tx =
    mint_test_case(TestCase { ..base_test_case(), is_datum_correct: False })
  !emergency_token.emergency_token.mint(
    mock_emergency_unlock_address(),
    redeemer,
    policy_id,
    tx,
  )
}

test t2_1_fail_mint_with_invalid_time() {
  let redeemer = EMint { minter: mock_user_vkey_hex() }
  let policy_id = mock_emergency_token()

  let tx = mint_test_case(TestCase { ..base_test_case(), is_time_valid: False })
  !emergency_token.emergency_token.mint(
    mock_emergency_unlock_address(),
    redeemer,
    policy_id,
    tx,
  )
}

test t2_2_success_burn() {
  let redeemer = EBurn
  let policy_id = mock_emergency_token()

  let tx = Transaction { ..placeholder, mint: from_asset(policy_id, #"", -1) }
  emergency_token.emergency_token.mint(
    mock_emergency_unlock_address(),
    redeemer,
    policy_id,
    tx,
  )
}

test t2_2_fail_burn_with_mint() {
  let redeemer = EBurn
  let policy_id = mock_emergency_token()

  let tx = Transaction { ..placeholder, mint: from_asset(policy_id, "", 1) }
  !emergency_token.emergency_token.mint(
    mock_emergency_unlock_address(),
    redeemer,
    policy_id,
    tx,
  )
}

test t2_2_fail_burn_with_mix() {
  let redeemer = EBurn
  let policy_id = mock_emergency_token()

  let tx =
    Transaction {
      ..placeholder,
      mint: from_asset(policy_id, "", -1) |> add(policy_id, "1", 1),
    }
  !emergency_token.emergency_token.mint(
    mock_emergency_unlock_address(),
    redeemer,
    policy_id,
    tx,
  )
}
