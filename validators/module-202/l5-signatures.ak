use aiken/transaction.{ScriptContext, Spend, Transaction}
use mocktail.{complete, mocktail_tx, required_signer_hash}
use mocktail/virgin_key_hex.{mock_pub_key_hash}
use mocktail/virgin_output_reference.{mock_utxo_ref}
use vodka_extra_signatories.{key_signed}

type Datum {
  owner: ByteArray,
}

/// Learning objecting
/// 1. Familiar with data type short hand form (only one constructor)
/// 2. Learn about SIDAN utils in checking signature
/// 3. Can distinguish between: who signed the transaction vs who is required to signed the transaction -> building early concept on cardano validator
/// 4. Learn building required signers with SIDAN tx builder
validator {
  fn check_signatures_spending_validator(
    datum: Datum,
    _redeemer: Data,
    context: ScriptContext,
  ) {
    let Transaction { extra_signatories, .. } = context.transaction
    key_signed(extra_signatories, datum.owner)
  }
}

type TestCase {
  is_key_signed: Bool,
}

fn mock_tx(test_case: TestCase) -> Transaction {
  let TestCase { is_key_signed } = test_case
  mocktail_tx()
    |> required_signer_hash(is_key_signed, mock_pub_key_hash(0))
    |> complete()
}

test m202_l5_test_success() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(TestCase { is_key_signed: True }),
    }
  let datum = Datum { owner: mock_pub_key_hash(0) }
  check_signatures_spending_validator(datum, Void, context)
}

test m202_l5_test_failed_without_signer() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(TestCase { is_key_signed: False }),
    }
  let datum = Datum { owner: mock_pub_key_hash(0) }
  !check_signatures_spending_validator(datum, Void, context)
}

test m202_l5_test_failed_with_incorrect_signer() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(TestCase { is_key_signed: True }),
    }
  let datum = Datum { owner: mock_pub_key_hash(1) }
  !check_signatures_spending_validator(datum, Void, context)
}
