use account_oracle
use aiken/collection/list
use aiken_game_account/placeholder.{
  mock_account_oracle_datum, mock_account_oracle_output, mock_stop_key,
} as game_placeholder
use aiken_game_account/types.{AccountOracleDatum, RotateKey}
use cardano/transaction.{Input, Transaction, placeholder}
use mocktail/virgin_key_hash.{mock_pub_key_hash}
use mocktail/virgin_output_reference.{mock_utxo_ref}

type RotateTestCase {
  is_old_stop_key_signed: Bool,
  is_new_stop_key_signed: Bool,
  is_datum_updated: Bool,
}

fn base_rotate_test_case() {
  RotateTestCase {
    is_old_stop_key_signed: True,
    is_new_stop_key_signed: True,
    is_datum_updated: True,
  }
}

fn mock_rotate_test_case(test_case: RotateTestCase) {
  let RotateTestCase {
    is_old_stop_key_signed,
    is_new_stop_key_signed,
    is_datum_updated,
  } = test_case
  let input_utxo = mock_utxo_ref(0, 0)
  let new_stop_key = mock_pub_key_hash(3)

  let extra_signatories =
    []
      |> list.concat(
          if is_old_stop_key_signed {
            [mock_stop_key()]
          } else {
            []
          },
        )
      |> list.concat(
          if is_new_stop_key_signed {
            [new_stop_key]
          } else {
            []
          },
        )
  let new_datum =
    if is_datum_updated {
      AccountOracleDatum {
        ..mock_account_oracle_datum(),
        operation_key: mock_stop_key(),
        stop_key: new_stop_key,
      }
    } else {
      mock_account_oracle_datum()
    }

  let input =
    Input {
      output_reference: input_utxo,
      output: mock_account_oracle_output(mock_account_oracle_datum()),
    }
  let output = mock_account_oracle_output(new_datum)
  Transaction {
    ..placeholder,
    inputs: [input],
    outputs: [output],
    extra_signatories: extra_signatories,
  }
}

test t4_1_success_rotate_key() {
  let redeemer =
    RotateKey {
      new_operation_key: mock_stop_key(),
      new_stop_key: mock_pub_key_hash(3),
    }
  let input_utxo = mock_utxo_ref(0, 0)

  let tx = mock_rotate_test_case(base_rotate_test_case())

  account_oracle.account_oracle.spend(
    Some(mock_account_oracle_datum()),
    redeemer,
    input_utxo,
    tx,
  )
}

test t4_1_fail_rotate_key_without_old_stop_signature() {
  let redeemer =
    RotateKey {
      new_operation_key: mock_stop_key(),
      new_stop_key: mock_pub_key_hash(3),
    }
  let input_utxo = mock_utxo_ref(0, 0)

  let tx =
    mock_rotate_test_case(
      RotateTestCase {
        ..base_rotate_test_case(),
        is_old_stop_key_signed: False,
      },
    )

  !account_oracle.account_oracle.spend(
    Some(mock_account_oracle_datum()),
    redeemer,
    input_utxo,
    tx,
  )
}

test t4_1_fail_rotate_key_without_new_stop_signature() {
  let redeemer =
    RotateKey {
      new_operation_key: mock_stop_key(),
      new_stop_key: mock_pub_key_hash(3),
    }
  let input_utxo = mock_utxo_ref(0, 0)

  let tx =
    mock_rotate_test_case(
      RotateTestCase {
        ..base_rotate_test_case(),
        is_new_stop_key_signed: False,
      },
    )

  !account_oracle.account_oracle.spend(
    Some(mock_account_oracle_datum()),
    redeemer,
    input_utxo,
    tx,
  )
}
