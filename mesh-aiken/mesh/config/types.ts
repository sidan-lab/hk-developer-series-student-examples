import { ConStr0, PolicyId, PubKeyHash, ScriptAddress } from "@meshsdk/core";

export type OracleDatum = ConStr0<
  [PolicyId, ScriptAddress, PubKeyHash, PolicyId, PubKeyHash]
>;
