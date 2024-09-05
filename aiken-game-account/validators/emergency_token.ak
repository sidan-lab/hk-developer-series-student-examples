use aiken_game_account/types.{
  EBurn, EMint, EmergencyTokenMintingPolarity, EmergencyUnlockDatum,
}
use cardano/address.{Address}
use cardano/assets.{PolicyId}
use cardano/transaction.{Transaction}
use vodka_extra_signatories.{key_signed}
use vodka_mints.{check_policy_only_burn, only_minted_token}
use vodka_outputs.{output_inline_datum, outputs_at_with}
use vodka_validity_range.{valid_before}

validator emergency_token(emergency_unlock_address: Address) {
  mint(
    redeemer: EmergencyTokenMintingPolarity,
    policy_id: PolicyId,
    tx: Transaction,
  ) {
    when redeemer is {
      EMint { minter } -> {
        let Transaction { outputs, mint, extra_signatories, validity_range, .. } =
          tx
        expect [emergency_output] =
          outputs_at_with(outputs, emergency_unlock_address, policy_id, minter)
        expect EmergencyUnlockDatum { minted_at } =
          output_inline_datum(emergency_output)
        let is_emergency_token_minted =
          only_minted_token(mint, policy_id, minter, 1)
        let is_owner_signed = key_signed(extra_signatories, minter)
        // It should be that the token is guaranteed to be minted before the current timestamp
        let is_time_valid = valid_before(validity_range, minted_at)
        is_owner_signed? && is_emergency_token_minted? && is_time_valid?
      }
      EBurn -> {
        let Transaction { mint, .. } = tx
        let is_only_burned = check_policy_only_burn(mint, policy_id)
        is_only_burned?
      }
    }
  }

  else(_) {
    fail
  }
}
