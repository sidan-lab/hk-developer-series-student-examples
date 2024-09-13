import {
  ConStr0,
  Integer,
  PolicyId,
  PubKeyHash,
  ScriptAddress,
} from "@meshsdk/core";

export type OracleDatum = ConStr0<
  [PolicyId, ScriptAddress, PubKeyHash, PolicyId, PubKeyHash]
>;

export type EmergencyDatum = ConStr0<[Integer]>;

export type ScriptParams = {
  accountOracleParamUtxoTxHash?: string;
  accountOracleParamUtxoTxIndex?: number;
  ownerPubKeyHash?: string;
};
