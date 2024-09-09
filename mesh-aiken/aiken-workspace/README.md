# aiken-game-account

The repo serves the source code for game account. Game account is a set of smart contracts where the app owner takes away the immediate spending power of users in exchange for seamless UX for DApps.

## Setup

The are 2 steps of setting up the applications:

1. Minting `oracle_nft`, one time minting policy with empty token name with quantity of 1.

   - Validation: 1.1

2. Sending the the `oracle_nft` to `oracle_validator` with initialized inline datum of specifying all compile scripts, addresses with owner keys.

   - Validation: N/A

## User Actions

1. Account Setup. Sending reference script to account for later use

   - Validation: N/A

2. Deposit. Depoiting value into account.

   - Validation: N/A

3. Start Game. From account, sending value to game validator

   - Validation: 4.1

4. Close Game. Authorizing the value unlock from game validator

   - Validation: 5.1

5. Cancel Game. Withdrawing value from game with all user's signature for a staled game.

   - Validation: 5.2

6. Withdrawal. Withdrawing value from app.

   - Validation: 4.1 / 2.1 + 2.2 + 4.3 + 4.4

## Admin Actions

1. Rotate app keys. Changing the key configuration for running games and stopping app.

   - Validation: 3.1

2. Stop app. Burning oracle and stop app operation.

   - Validation: 1.2 + 3.2

3. Shuffle account utxos. Help users to change account utxos in a distribution easier for game operation.

   - Validation: 4.2
