# Specification - EmergencyUnlock

## Parameter

- `oracle_nft`: The policy id of account's `OracleNFT`

## Datum

- `minted_at`: The timestamp where the emergency withdraw buffer period start counting

## User Action

1. Unlock the emergency utxo

   - User Unlock Case

     - Only 1 reference utxo with `oracle_nft` with account oracle datum
     - Only 1 input with `emergency_token` & datum is in correct format
     - The current signing interval has `validity_interval_start` with `86400` slots after `minted_at`

   - Admin Unlock Case

     - Required `operation_key` signature plus anyone of below situation
       a. Request is expired (The current signing interval has `validity_interval_start` with `172800` slots after `minted_at`)
       b. No input (i.e. no current input containing `emergency_token`)
       c. The own input containing invalid datum
