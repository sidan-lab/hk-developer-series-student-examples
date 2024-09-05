# List of Smart Contracts

There are in total 5 scripts for the game account to work. Below provide description and pointers to a more detailed specs.

1. OracleNFT - [specification](./1_oracle_nft.md)

   - The one time minting policy, minting the NFT to be reference token locking in `OracleValidator`. It is used for serving static app information.

2. EmergencyToken - [specification](./2_emergency_token.md)

   - The minting policy for taking any withdrawal / cancel actions solely by users.

3. EmergencyUnlockValidator - [specification](./3_emergency_unlock.md)

   - The validator locking emergency token for withdrawal bypassing multi-sig

4. AccountOracle - [specification](./4_account_oracle.md)

   - The validator locking `OracleNFT`, for serving app static information on `Account` while protecting information integrity.

5. Account - [specification](./5_account/5_account.md)

   - The script to be compiled into different addresses according to account number, storing the UTxO ready for place order.
   - Action specification:
     - 5.1: User Unlock - [specification](./5_account/5.1_user_unlock.md)
     - 5.2: App Unlock - [specification](./5_account/5.2_app_unlock.md)

## Param Dependency Graph

1. First layer

   - 1.1 `OracleNFT` (param: `utxo_ref`)
   - 1.2 `OracleValidator` (no param)

2. Second layer

   - 2.1 All account actions (param: `owner`, 1.1, 1.2)
   - 2.2 `EmergencyUnlock` (param 1.2)

3. Third layer

   - 3.1 `EmergencyToken` (param: 2.2)

4. Fourth layer

   - 4.1 `Account` (param: 2.1, 2.2, 3.1)
