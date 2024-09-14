use cardano/assets.{from_lovelace}
use cardano/transaction.{Output, OutputReference, Transaction}
use mocktail.{
  complete, mocktail_tx, required_signer_hash, tx_out, tx_out_inline_datum,
}
use mocktail/virgin_address.{mock_pub_key_address}
use mocktail/virgin_key_hash.{mock_pub_key_hash}
use mocktail/virgin_output_reference.{mock_utxo_ref}
use vodka_address.{address_pub_key}
use vodka_extra_signatories.{key_signed}

pub type MyDatum {
  owner: ByteArray,
}

validator check_datum {
  spend(
    datum_opt: Option<MyDatum>,
    _redeemer: Data,
    _utxo: OutputReference,
    tx: Transaction,
  ) {
    expect Some(datum) = datum_opt
    let Transaction { outputs, extra_signatories, .. } = tx
    when outputs is {
      [only_output] ->
        when address_pub_key(only_output.address) is {
          Some(owner_pub_key) -> {
            // All output value send to owner
            // datum_opt == None <- program will just fail if thats the case

            let is_output_paid_to_owner = owner_pub_key == datum.owner
            // Is the owner signed?
            // expect Some(_) =
            //   list.find(extra_signatories, fn(sig) { sig == datum.owner })
            let is_owner_signed = key_signed(extra_signatories, datum.owner)

            is_output_paid_to_owner? && is_owner_signed?
          }

          _ -> False
        }

      _ -> False
    }
  }

  else(_) {
    fail
  }
}

type TestCase {
  is_only_one_output: Bool,
  is_owner_signed: Bool,
}

fn mock_tx(test_case: TestCase) -> Transaction {
  let TestCase { is_only_one_output, is_owner_signed } = test_case

  let datum = MyDatum { owner: mock_pub_key_hash(0) }
  // tx_out(mocktail_tx(), True, mock_pub_key_address(0, None), from_lovelace(100))
  mocktail_tx()
    |> tx_out(True, mock_pub_key_address(0, None), from_lovelace(100))
    |> tx_out(
        !is_only_one_output,
        mock_pub_key_address(0, None),
        from_lovelace(100),
      )
    |> tx_out_inline_datum(True, datum)
    |> required_signer_hash(is_owner_signed, mock_pub_key_hash(0))
    |> complete()
}

test test_spending_datum() {
  let datum = Some(MyDatum { owner: mock_pub_key_hash(0) })
  let tx = mock_tx(TestCase { is_only_one_output: True, is_owner_signed: True })
  check_datum.spend(datum, "", mock_utxo_ref(0, 0), tx)
}

test test_spending_datum_fail_without_owner_signature() {
  let datum = Some(MyDatum { owner: mock_pub_key_hash(0) })
  let tx =
    mock_tx(TestCase { is_only_one_output: True, is_owner_signed: False })
  !check_datum.spend(datum, "", mock_utxo_ref(0, 0), tx)
}

test test_spending_datum_fail_more_than_one_output() {
  let datum = Some(MyDatum { owner: mock_pub_key_hash(0) })
  let tx =
    mock_tx(TestCase { is_only_one_output: False, is_owner_signed: True })
  !check_datum.spend(datum, "", mock_utxo_ref(0, 0), tx)
}
