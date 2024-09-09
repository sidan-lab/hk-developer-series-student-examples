import { deserializeAddress } from "@meshsdk/core";
import { newWallet } from "../common";

export const operationWallet = newWallet(Array(24).fill("solution"));
export const stopWallet = newWallet(Array(24).fill("summer"));

export const operationKey = deserializeAddress(
  operationWallet.getUsedAddresses()[0]
).pubKeyHash;

export const stopKey = deserializeAddress(
  stopWallet.getUsedAddresses()[0]
).pubKeyHash;
