import { resolveScriptHash, UTxO } from "@meshsdk/core";
import blueprint from "../../aiken-workspace/plutus.json";
import { applyCborEncoding } from "@meshsdk/core-csl";

export const alwaySucceedMPCompileCode =
  "584501000032323232323222533300432323253330073370e900018041baa0011324a2600c0022c60120026012002600600229309b2b118021baa0015734aae7555cf2ba157441";
export const alwaysSucceedMPCbor = applyCborEncoding(alwaySucceedMPCompileCode);
export const alwaysSucceedMPPolicyId = resolveScriptHash(
  alwaysSucceedMPCbor,
  "V2"
);

export type InputUTxO = UTxO["input"];

export const stakeCred =
  "5ca749261aa3b17aa2cd4b026bc6566c4b14421d6083edce64ffe5cb";

export type ScriptIndex =
  | "Account"
  | "AccountAppUnlock"
  | "AccountUserUnlock"
  | "AccountOracleValidator"
  | "EmergencyToken"
  | "EmergencyUnlock"
  | "AccountOracleNFT";

export const scriptCompiledCode: Record<ScriptIndex, string> = {
  Account: blueprint.validators[0].compiledCode,
  AccountAppUnlock: blueprint.validators[2].compiledCode,
  AccountUserUnlock: blueprint.validators[5].compiledCode,
  AccountOracleValidator: blueprint.validators[6].compiledCode,
  EmergencyToken: blueprint.validators[8].compiledCode,
  EmergencyUnlock: blueprint.validators[10].compiledCode,
  AccountOracleNFT: blueprint.validators[12].compiledCode,
};
