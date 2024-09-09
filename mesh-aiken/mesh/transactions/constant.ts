import { applyCborEncoding, applyParamsToScript } from "@meshsdk/core-csl";
import blueprint from "../../aiken-workspace/plutus.json";
import {
  mOutputReference,
  mScriptAddress,
  resolveScriptHash,
  serializePlutusScript,
} from "@meshsdk/core";

export type ScriptParam = {
  oracleTxHash: string;
  oracleTxIndex: number;
  ownerPubKeyHash: string;
};

export type ScriptIndex =
  | "OracleNFT"
  | "AccountOracle"
  | "EmergencyToken"
  | "EmergencyUnlock"
  | "Account"
  | "AppUnlock"
  | "UserUnlock";

export const getScriptRawCode = (index: ScriptIndex) => {
  const validators = blueprint.validators;
  switch (index) {
    case "OracleNFT":
      return validators[12].compiledCode;
    case "AccountOracle":
      return validators[6].compiledCode;
    case "EmergencyToken":
      return validators[8].compiledCode;
    case "EmergencyUnlock":
      return validators[10].compiledCode;
    case "Account":
      return validators[0].compiledCode;
    case "AppUnlock":
      return validators[2].compiledCode;
    case "UserUnlock":
      return validators[5].compiledCode;
    default:
      throw new Error("Invalid script index");
  }
};

export const getScriptCbors = (index: ScriptIndex, param: ScriptParam) => {
  const accountOracle = applyCborEncoding(getScriptRawCode("AccountOracle"));
  const oracleNFT = applyParamsToScript(getScriptRawCode("OracleNFT"), [
    mOutputReference(param.oracleTxHash, param.oracleTxIndex),
  ]);
  const oraclePolicyId = resolveScriptHash(oracleNFT, "V3");
  const emergencyUnlock = applyParamsToScript(
    getScriptRawCode("EmergencyUnlock"),
    [oraclePolicyId]
  );
  const emergencyUnlockScriptHash = resolveScriptHash(emergencyUnlock, "V3");
  const emergencyToken = applyParamsToScript(
    getScriptRawCode("EmergencyToken"),
    [mScriptAddress(emergencyUnlockScriptHash)]
  );
  const appUnlock = applyParamsToScript(getScriptRawCode("AppUnlock"), [
    oraclePolicyId,
  ]);
  const userUnlock = applyParamsToScript(getScriptRawCode("UserUnlock"), [
    oraclePolicyId,
    param.ownerPubKeyHash,
  ]);
  const account = applyParamsToScript(getScriptRawCode("Account"), [
    param.ownerPubKeyHash,
    resolveScriptHash(userUnlock, "V3"),
    resolveScriptHash(userUnlock, "V3"),
    resolveScriptHash(appUnlock, "V3"),
    resolveScriptHash(emergencyToken, "V3"),
  ]);

  switch (index) {
    case "OracleNFT":
      return oracleNFT;
    case "AccountOracle":
      return accountOracle;
    case "EmergencyToken":
      return emergencyToken;
    case "EmergencyUnlock":
      return emergencyUnlock;
    case "Account":
      return account;
    case "AppUnlock":
      return appUnlock;
    case "UserUnlock":
      return userUnlock;
    default:
      throw new Error("Invalid script index");
  }
};

export const getScriptHash = (index: ScriptIndex, param: ScriptParam) => {
  const scriptCbor = getScriptCbors(index, param);
  return resolveScriptHash(scriptCbor, "V3");
};
