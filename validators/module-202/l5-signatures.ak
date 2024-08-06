use aiken/transaction.{ScriptContext, Spend, Transaction}
use sidan_placeholder/builder.{complete, new_tx_tester, required_signer_hash}
use sidan_placeholder/key_hex.{mock_pub_key_hex}
use sidan_placeholder/output_reference.{mock_utxo_ref}
use sidan_utils/extra_signatories.{key_signed}

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
  new_tx_tester()
    |> required_signer_hash(is_key_signed, mock_pub_key_hex(0))
    |> complete()
}

test m202_l5_test_success() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(TestCase { is_key_signed: True }),
    }
  let datum = Datum { owner: mock_pub_key_hex(0) }
  check_signatures_spending_validator(datum, Void, context)
}

test m202_l5_test_failed_without_signer() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(TestCase { is_key_signed: False }),
    }
  let datum = Datum { owner: mock_pub_key_hex(0) }
  !check_signatures_spending_validator(datum, Void, context)
}

test m202_l5_test_failed_with_incorrect_signer() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(TestCase { is_key_signed: True }),
    }
  let datum = Datum { owner: mock_pub_key_hex(1) }
  !check_signatures_spending_validator(datum, Void, context)
}
