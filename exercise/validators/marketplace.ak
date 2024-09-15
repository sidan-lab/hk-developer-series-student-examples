use cardano/address.{Address}
use cardano/assets.{Value, from_lovelace, lovelace_of}
use cardano/transaction.{OutputReference, Transaction, find_input}
use vodka_address.{address_pub_key}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{inputs_at}
use vodka_value.{get_all_value_to, value_geq}

/// Classwork: Build a marketplace validator where
/// 
/// Parameters:
/// 1. owner: owner address of the marketplace (who will be receiving the fee)
/// 2. fee_percentage_basis_point: fee percentage basis point (1 basis point = 0.01%)
///
/// User Actions:
/// 1. Buy: who ever send the `price` amount of lovelace to the `seller` address, 
///    and pay the fee to the `owner` address can unlock the token
/// 2. Close: only the `seller` can close the marketplace (checking signature)
///
/// Hints - There are some utility functions that can be used in this exercise:
/// 1. from_lovelace
/// 2. lovelace_of
/// 3. address_pub_key - obtain public key from `Address`
/// 4. key_signed - check signature
/// 5. find_input - find input by OutputReference
/// 6. get_all_value_to - provide `List<Output>` and `Address` to get all the Value to the address
/// 7. value_geq - comparing value (first Value > second Value)
pub type MarketplaceDatum {
  seller: Address,
  price: Int,
  // e.g. 2_000_000 == 2ADA
  policy: ByteArray,
  tokenName: ByteArray,
}

pub type MarketplaceRedeemer {
  Buy
  Close
}

validator marketplace(owner: Address, fee_percentage_basis_point: Int) {
  spend(
    datum_opt: Option<MarketplaceDatum>,
    redeemer: MarketplaceRedeemer,
    utxo: OutputReference,
    tx: Transaction,
  ) {
    expect Some(datum) = datum_opt
    when redeemer is {
      Buy -> {
        // 1. Try the current input
        expect Some(own_input) = find_input(tx.inputs, utxo)
        let own_address = own_input.output.address
        expect [_] = inputs_at(tx.inputs, own_address)

        // seller asking for 2 ada
        // owner (aka me) want to charge 10% (fee_percentage_basis_point = 1000)
        // 2 ada * 10% = 0.2 ada
        let expected_lovelace_seller_to_receive = from_lovelace(datum.price)
        let expected_lovelace_owner_to_receive =
          from_lovelace(datum.price * fee_percentage_basis_point / 10000)
        let actual_value_to_seller: Value =
          get_all_value_to(tx.outputs, datum.seller)
        let actual_value_to_owner: Value = get_all_value_to(tx.outputs, owner)
        let is_proceed_paid_to_seller =
          value_geq(actual_value_to_seller, expected_lovelace_seller_to_receive)
        let is_fee_paid_to_owner =
          value_geq(actual_value_to_owner, expected_lovelace_owner_to_receive)
        is_proceed_paid_to_seller? && is_fee_paid_to_owner?
      }

      Close -> {
        let extra_signatories = tx.extra_signatories
        expect Some(seller_pub_key) = address_pub_key(datum.seller)
        key_signed(extra_signatories, seller_pub_key)
      }
    }
  }

  else(_) {
    fail
  }
}
