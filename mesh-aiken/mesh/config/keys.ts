import { deserializeAddress } from "@meshsdk/core";
import { newWallet } from "./wallet";

export const refScriptWallet = newWallet(Array(24).fill("flag"));
export const operationWallet = newWallet(Array(24).fill("solution"));
export const stopWallet = newWallet(Array(24).fill("summer"));

export const operationKey = deserializeAddress(
  operationWallet.getUsedAddresses()[0]
).pubKeyHash;

export const stopKey = deserializeAddress(
  stopWallet.getUsedAddresses()[0]
).pubKeyHash;

// flag wallet
export const refScriptsAddress = refScriptWallet.getUsedAddresses()[0];

// Summer wallet
export const operationAddress = operationWallet.getUsedAddresses()[0];
