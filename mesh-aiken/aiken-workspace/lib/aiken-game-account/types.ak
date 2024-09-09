use cardano/address.{Address}
use cardano/assets.{PolicyId}

// 1. OracleNFT
pub type MintPolarity {
  RMint
  RBurn
}

// 2. EmergencyToken
pub type EmergencyTokenMintingPolarity {
  EMint { minter: ByteArray }
  EBurn
}

// 3. EmergencyUnlock Validator

pub type EmergencyUnlockDatum {
  minted_at: Int,
}

// 4. AccountOracle
pub type AccountOracleDatum {
  oracle_nft: PolicyId,
  oracle_address: Address,
  operation_key: ByteArray,
  emergency_token: PolicyId,
  stop_key: ByteArray,
}

pub type AccountOracleRedeemer {
  RotateKey { new_operation_key: ByteArray, new_stop_key: ByteArray }
}

// 5. Account
pub type AccountRedeemer {
  AccountUserUnlock1
  AccountUserUnlock2
  AccountAppUnlock
  AccountEmergencyUnlock
}

pub type AccountDatum {
  AccountDatum
}
