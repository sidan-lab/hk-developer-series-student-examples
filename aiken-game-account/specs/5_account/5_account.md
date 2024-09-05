# Specification - Account

## Parameter

- `owner`: The pub key hash of account owner
- `user_unlock_1`: The script hash of `user_unlock` withdrawal script with first key
- `user_unlock_2`: The script hash of `user_unlock` withdrawal script with second key
- `app_unlock`: The script hash of `app_unlock` withdrawal script
- `emergency_unlock_phase1`: The script hash of `emergency_unlock_phase1` withdrawal script
- `emergency_unlock_phase2`: The script hash of `emergency_unlock_phase2` withdrawal script

## Datum

1. AccountNormalDatum

   - Stating that the UTxO is ready for normal app operation, including placing orders, taking orders and authorized withdrawal

2. EmergencyUnlockPhase1 {owner}

   - Stating that the UTxO is ready to be the authorization input for minting the emergency token.

3. EmergencyUnlockPhase2 {valid_since, minter}

   - Stating that the UTxO is attached with an emergency token, ready for user withdrawal without passing through application logic

## User Action

1. User Unlock - Redeemer `AccountUserUnlock1`

   - Withdrawal script of `user_unlock_1` validating

2. User Unlock - Redeemer `AccountUserUnlock2`

   - Withdrawal script of `user_unlock_2` validating

3. App Unlock - Redeemer `AccountAppUnlock`

   - Withdrawal script of `app_unlock` validating

4. Emergency operation phase 2 - Redeemer `AccountEmergencyUnlockPhase2 {owner, withdraw_output}`

   - Supplying owner and own_input information for the withdrawal script
   - Withdrawal script of `emergency_unlock_phase2` validating
