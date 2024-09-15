use cardano/address.{Address}
use cardano/assets.{from_lovelace, lovelace_of}
use cardano/transaction.{OutputReference, Transaction, find_input}
use vodka_address.{address_pub_key}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{inputs_at}
use vodka_value.{get_all_value_to, value_geq}

pub type MarketplaceDatum {
  seller: Address,
  price: Int,
  policy: ByteArray,
  tokenName: ByteArray,
}

pub type MarketplaceRedeemer {
  Buy
  Close
}

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
/// 5. inputs_at - filter inputs by `Address`
/// 6. find_input - find input by OutputReference
/// 7. get_all_value_to - provide `List<Output>` and `Address` to get all the Value to the address
/// 8. value_geq - comparing value (first Value > second Value)
validator marketplace(owner: Address, fee_percentage_basis_point: Int) {
  spend(
    datum_opt: Option<MarketplaceDatum>,
    redeemer: MarketplaceRedeemer,
    input: OutputReference,
    tx: Transaction,
  ) {
    when redeemer is {
      Buy -> todo
      Close -> todo
    }
  }

  else(_) {
    fail
  }
}
