import { newWallet } from "./wallet";
import { deserializeBech32Address } from "@meshsdk/core-csl";

export const refScriptWallet = newWallet(Array(24).fill("flag"));
export const operationWallet = newWallet(Array(24).fill("solution"));
export const stopWallet = newWallet(Array(24).fill("summer"));
export const player1Wallet = newWallet(Array(24).fill("they"));
export const player2Wallet = newWallet(Array(24).fill("trade"));

// flag wallet
export const refScriptsAddress = refScriptWallet.getUsedAddresses()[0]!;

// Summer wallet
export const operationAddress = operationWallet.getUsedAddresses()[0]!;

export const deserializedOpsPlutusAddr =
  deserializeBech32Address(operationAddress);
export const deserializedStopPlutusAddr =
  deserializeBech32Address(refScriptsAddress);
export const opsKey = deserializedOpsPlutusAddr.pubKeyHash;
export const stopKey = deserializedStopPlutusAddr.pubKeyHash;
