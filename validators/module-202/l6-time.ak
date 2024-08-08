use aiken/transaction.{ScriptContext, Spend, Transaction}
use mocktail.{complete, invalid_before, invalid_hereafter, mocktail_tx}
use mocktail/virgin_output_reference.{mock_utxo_ref}
use vodka_validity_range.{valid_after, valid_before}

type Datum {
  must_be_after: Int,
  must_be_before: Int,
}

/// Learning objecting
/// 1. Familiar with data type short hand form (only one constructor)
/// 2. Learn about SIDAN utils in checking time range
/// 3. Can distinguish between: when does the tx happened vs in which timeframe must the tx happened -> building early concept on cardano validator
/// 4. Learn building valid tx time range with SIDAN tx builder
validator {
  fn check_time_spending_validator(
    datum: Datum,
    _redeemer: Data,
    context: ScriptContext,
  ) {
    let Transaction { validity_range, .. } = context.transaction
    let is_upper_bound_correct =
      valid_before(validity_range, datum.must_be_before)
    let is_lower_bound_correct =
      valid_after(validity_range, datum.must_be_after)
    is_upper_bound_correct? && is_lower_bound_correct?
  }
}

type TestCase {
  is_tx_before_valid_upper_bound: Bool,
  is_tx_after_valid_lower_bound: Bool,
}

fn mock_tx(test_case: TestCase) -> Transaction {
  let TestCase { is_tx_before_valid_upper_bound, is_tx_after_valid_lower_bound } =
    test_case
  mocktail_tx()
    |> invalid_hereafter(is_tx_before_valid_upper_bound, 199)
    |> invalid_before(is_tx_after_valid_lower_bound, 101)
    |> complete()
}

test m202_l6_test_success() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(
        TestCase {
          is_tx_before_valid_upper_bound: True,
          is_tx_after_valid_lower_bound: True,
        },
      ),
    }
  let datum = Datum { must_be_after: 100, must_be_before: 200 }
  check_time_spending_validator(datum, Void, context)
}

test m202_l6_test_failed_with_invalid_before() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(
        TestCase {
          is_tx_before_valid_upper_bound: False,
          is_tx_after_valid_lower_bound: True,
        },
      ),
    }
  let datum = Datum { must_be_after: 100, must_be_before: 200 }
  !check_time_spending_validator(datum, Void, context)
}

test m202_l6_test_failed_with_invalid_hereafter() {
  let context =
    ScriptContext {
      purpose: Spend(mock_utxo_ref(0, 0)),
      transaction: mock_tx(
        TestCase {
          is_tx_before_valid_upper_bound: True,
          is_tx_after_valid_lower_bound: False,
        },
      ),
    }
  let datum = Datum { must_be_after: 100, must_be_before: 200 }
  !check_time_spending_validator(datum, Void, context)
}
