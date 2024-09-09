use aiken/collection/list
use aiken_game_account/types.{AccountOracleDatum}
use cardano/address.{Credential}
use cardano/assets.{PolicyId, merge, zero}
use cardano/certificate.{Certificate}
use cardano/transaction.{Transaction}
use vodka_address.{address_script_hash}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{only_input_datum_with}
use vodka_value.{get_all_value_to, value_geq} as sidan_value

validator account_app_unlock(oracle_nft: PolicyId) {
  withdraw(_redeemer: Data, _credential: Credential, tx: Transaction) {
    let Transaction { inputs, outputs, extra_signatories, reference_inputs, .. } =
      tx
    expect AccountOracleDatum { operation_key, .. }: AccountOracleDatum =
      only_input_datum_with(reference_inputs, oracle_nft, "")

    let (
      is_only_single_script_address,
      maybe_script_address,
      account_input_value,
    ) =
      list.foldr(
        inputs,
        (True, None, zero),
        fn(input, acc) {
          when address_script_hash(input.output.address) is {
            None -> acc
            Some(_) -> {
              let current_address = input.output.address
              let is_address_valid =
                when acc.2nd is {
                  None -> True
                  Some(script_address) -> script_address == current_address
                }
              let total_value = merge(acc.3rd, input.output.value)
              (is_address_valid, Some(current_address), total_value)
            }
          }
        },
      )

    when maybe_script_address is {
      Some(script_address) -> {
        let account_output_value = get_all_value_to(outputs, script_address)
        let is_operation_key_signed =
          key_signed(extra_signatories, operation_key)
        let is_value_preserved =
          account_output_value |> value_geq(account_input_value)
        is_only_single_script_address && is_operation_key_signed && is_value_preserved
      }
      None -> False
    }
  }

  publish(_redeemer: Data, _credential: Certificate, tx: Transaction) {
    let Transaction { reference_inputs, .. } = tx
    expect AccountOracleDatum { operation_key, .. }: AccountOracleDatum =
      only_input_datum_with(reference_inputs, oracle_nft, "")
    key_signed(tx.extra_signatories, operation_key)
  }

  else(_) {
    fail
  }
}
