use cardano/transaction.{OutputReference, Transaction, placeholder}
use mocktail/virgin_output_reference.{mock_utxo_ref}

pub type Redeemer {
  SuccessRedeemer
  FailRedeemer
}

/// Learning objecting
/// 1. Familiar with control flow pattern of routing redeemer to different validation logics
validator check_redeemer {
  spend(
    _datum: Option<Data>,
    redeemer: Redeemer,
    _input: OutputReference,
    _tx: Transaction,
  ) {
    when redeemer is {
      SuccessRedeemer -> True
      FailRedeemer -> False
    }
  }

  else(_) {
    fail
  }
}

test m202_l1_test_success_redeemer() {
  let redeemer = SuccessRedeemer
  check_redeemer.spend(None, redeemer, mock_utxo_ref(0, 0), placeholder)
}

test m202_l1_test_fail_redeemer() {
  let redeemer = FailRedeemer
  !check_redeemer.spend(None, redeemer, mock_utxo_ref(0, 0), placeholder)
}
