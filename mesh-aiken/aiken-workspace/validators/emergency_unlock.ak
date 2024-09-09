use aiken_game_account/types.{AccountOracleDatum, EmergencyUnlockDatum}
use cardano/assets.{PolicyId}
use cardano/transaction.{OutputReference, Transaction}
use vodka_extra_signatories.{key_signed}
use vodka_inputs.{inputs_with_policy, only_input_datum_with}
use vodka_mints.{only_minted_token}
use vodka_outputs.{output_inline_datum}
use vodka_validity_range.{valid_after}
use vodka_value.{value_policy_info}

validator emergency_unlock(oracle_nft: PolicyId) {
  spend(
    _datum: Option<Data>,
    _redeemer: Data,
    _input: OutputReference,
    tx: Transaction,
  ) {
    let Transaction {
      reference_inputs,
      inputs,
      extra_signatories,
      validity_range,
      mint,
      ..
    } = tx
    expect AccountOracleDatum { emergency_token, operation_key, .. }: AccountOracleDatum =
      only_input_datum_with(reference_inputs, oracle_nft, "")
    let emergency_inputs = inputs_with_policy(inputs, emergency_token)
    let is_admin_signed = key_signed(extra_signatories, operation_key)
    when emergency_inputs is {
      [emergency_input] -> {
        let emergency_token_info =
          value_policy_info(emergency_input.output.value, emergency_token)
        when
          (emergency_token_info, output_inline_datum(emergency_input.output))
        is {
          (Some((_, asset_name, _)), emergency_datum) -> {
            let is_owner_signed = key_signed(extra_signatories, asset_name)
            if emergency_datum is EmergencyUnlockDatum {
              let is_after_2days =
                valid_after(
                  validity_range,
                  emergency_datum.minted_at + 172_800_001,
                )
              let is_after_1days =
                valid_after(
                  validity_range,
                  emergency_datum.minted_at + 86_400_001,
                )
              let is_emergency_token_burnt =
                only_minted_token(mint, emergency_token, asset_name, -1)
              let admin_unlock = is_after_2days? && is_admin_signed?
              let user_unlock =
                is_after_1days? && !is_after_2days && is_emergency_token_burnt? && is_owner_signed?
              admin_unlock? || user_unlock?
            } else {
              is_admin_signed?
            }
          }
          _ -> is_admin_signed?
        }
      }
      _ -> is_admin_signed?
    }
  }

  else(_) {
    fail
  }
}
