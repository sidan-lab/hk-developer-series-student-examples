# Specification - EmergencyToken

## Parameter

- `emergency_unlock_address`: The output address locking the emergency token

## User Action

1. Mint - Redeemer `EMint { minter }`

   - Must be signed by owner
   - There is only 1 token minted (current policy), with token name encoded owner
   - There must be 1 output to `emergency_unlock_address`
   - The output datum to `emergency_unlock_address` with `minted_at` information
   - The transaction must be before `minted_at`

2. Burn - Redeemer `EBurn`

   - Check the current policy only containing burning
