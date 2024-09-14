use cardano/transaction.{OutputReference, Transaction, placeholder}
use mocktail/virgin_output_reference.{mock_utxo_ref}

pub type MyRedeemer {
  Success
  Fail
}

validator check_redeemer {
  spend(
    _datum_opt: Option<Data>,
    redeemer: MyRedeemer,
    _utxo: OutputReference,
    _tx: Transaction,
  ) {
    when redeemer is {
      Success -> True
      Fail -> False
    }
  }

  else(_) {
    fail
  }
}

test test_check_simple_redeemer() {
  let datum_cannot_control: Data = "hinson"
  let my_redeemer = Success
  check_redeemer.spend(
    Some(datum_cannot_control),
    my_redeemer,
    mock_utxo_ref(0, 0),
    placeholder,
  )
}

test test_check_simple_redeemer_fail() {
  let datum_cannot_control: Data = "hinson"
  let my_redeemer = Fail
  !check_redeemer.spend(
    Some(datum_cannot_control),
    my_redeemer,
    mock_utxo_ref(0, 0),
    placeholder,
  )
}
