import { deserializeAddress, IFetcher } from "@meshsdk/core";
import { deserializeBech32Address } from "@meshsdk/core-csl";

import { AppWalletKeyType, MeshWallet } from "@meshsdk/core";

export const newWallet = (providedMnemonic?: string[], provider: IFetcher) => {
  let mnemonic = providedMnemonic;
  if (!providedMnemonic) {
    mnemonic = MeshWallet.brew() as string[];
    console.log(
      "Wallet generated, if you want to reuse the same address, please save the mnemonic:"
    );
    console.log(mnemonic);
  }
  const signingKey: AppWalletKeyType = {
    type: "mnemonic",
    words: mnemonic as string[],
  };

  const wallet = new MeshWallet({
    key: signingKey,
    networkId: 0,
    fetcher: provider,
    submitter: provider,
  });
  return wallet;
};

export const refScriptWallet = newWallet(Array(24).fill("flag"));
export const operationWallet = newWallet(Array(24).fill("solution"));
export const stopWallet = newWallet(Array(24).fill("summer"));

// flag wallet
export const refScriptsAddress = refScriptWallet.getUsedAddresses()[0];

// Summer wallet
export const operationAddress = operationWallet.getUsedAddresses()[0];

export const deserializedOpsPlutusAddr =
  deserializeBech32Address(operationAddress);
export const deserializedStopPlutusAddr =
  deserializeBech32Address(refScriptsAddress);
export const opsKey = deserializedOpsPlutusAddr.pubKeyHash;
export const stopKey = deserializedStopPlutusAddr.pubKeyHash;
