import {
  MeshWallet,
  MeshTxBuilder,
  deserializeAddress,
  UTxO,
  mConStr0,
  mScriptAddress,
  byteString,
  outputReference,
  pubKeyHash,
  resolveScriptHash,
  scriptAddress,
  serializePlutusScript,
} from "@meshsdk/core";
import { scriptCompiledCode, ScriptIndex, stakeCred } from "./constant";
import { provider } from "./provider";
import {
  applyParamsToScript,
  applyCborEncoding,
  deserializeBech32Address,
} from "@meshsdk/core-csl";
import { ScriptParams } from "./types";
import { operationAddress, refScriptsAddress } from "./keys";

export const getScriptCbor = (
  scriptIndex: ScriptIndex,
  {
    accountOracleParamUtxoTxHash,
    accountOracleParamUtxoTxIndex,
    ownerPubKeyHash,
  }: ScriptParams
) => {
  // Compile first layer of the scripts

  let accountOracleNFTCbor = "";
  if (
    accountOracleParamUtxoTxHash &&
    typeof accountOracleParamUtxoTxIndex === "number"
  ) {
    accountOracleNFTCbor = applyParamsToScript(
      scriptCompiledCode.AccountOracleNFT,
      [
        outputReference(
          accountOracleParamUtxoTxHash,
          accountOracleParamUtxoTxIndex
        ),
      ],
      "JSON"
    );
  }
  const accountOracleNFTParam = byteString(
    resolveScriptHash(accountOracleNFTCbor, "V3")
  );
  const accountOracleValidatorCbor = applyCborEncoding(
    scriptCompiledCode.AccountOracleValidator
  );

  const emergencyUnlockCbor = applyParamsToScript(
    scriptCompiledCode.EmergencyUnlock,
    [accountOracleNFTParam],
    "JSON"
  );
  const emergencyUnlockScriptHash = resolveScriptHash(
    emergencyUnlockCbor,
    "V3"
  );
  const emergencyUnlockAddress = scriptAddress(
    emergencyUnlockScriptHash,
    stakeCred
  );
  const emergencyTokenCbor = applyParamsToScript(
    scriptCompiledCode.EmergencyToken,
    [emergencyUnlockAddress],
    "JSON"
  );
  const emergencyTokenPolicyId = resolveScriptHash(emergencyTokenCbor, "V3");

  // Compile second layer of the scripts
  const appUnlockCbor = applyParamsToScript(
    scriptCompiledCode.AccountAppUnlock,
    [accountOracleNFTParam],
    "JSON"
  );
  let userUnlockCbor, accountCbor;
  if (ownerPubKeyHash) {
    const ownerPubKeyHashParam = pubKeyHash(ownerPubKeyHash);
    userUnlockCbor = applyParamsToScript(
      scriptCompiledCode.AccountUserUnlock,
      [accountOracleNFTParam, ownerPubKeyHashParam],
      "JSON"
    );
    const userUnlockScriptHash = resolveScriptHash(userUnlockCbor, "V3");
    const appUnlockScriptHash = resolveScriptHash(appUnlockCbor, "V3");
    accountCbor = applyParamsToScript(scriptCompiledCode.Account, [
      ownerPubKeyHash,
      userUnlockScriptHash,
      userUnlockScriptHash,
      appUnlockScriptHash,
      emergencyTokenPolicyId,
    ]);
  }

  switch (scriptIndex) {
    case "Account":
      return accountCbor || "";
    case "AccountAppUnlock":
      return appUnlockCbor || "";
    case "AccountUserUnlock":
      return userUnlockCbor || "";
    case "AccountOracleValidator":
      return accountOracleValidatorCbor || "";
    case "EmergencyToken":
      return emergencyTokenCbor || "";
    case "EmergencyUnlock":
      return emergencyUnlockCbor || "";
    case "AccountOracleNFT":
      return accountOracleNFTCbor || "";
  }
};

export const getScriptHash = (
  scriptIndex: ScriptIndex,
  scriptParams: ScriptParams
) => {
  const scriptCbor = getScriptCbor(scriptIndex, scriptParams);
  if (scriptCbor) {
    return resolveScriptHash(scriptCbor, "V3");
  }
  return "";
};

export const getValidatorAddress = (
  scriptIndex: Omit<ScriptIndex, "OracleNFT" | "EmergencyToken">,
  scriptParams: ScriptParams
) => {
  const scriptCbor = getScriptCbor(scriptIndex as ScriptIndex, scriptParams);
  if (scriptCbor) {
    return serializePlutusScript(
      { code: scriptCbor, version: "V3" },
      stakeCred,
      0,
      false
    ).address;
  }
  return "";
};

export const deserializedOpsPlutusAddr =
  deserializeBech32Address(operationAddress);
export const deserializedStopPlutusAddr =
  deserializeBech32Address(refScriptsAddress);
export const opsKey = deserializedOpsPlutusAddr.pubKeyHash;
export const stopKey = deserializedStopPlutusAddr.pubKeyHash;

export const allScriptInfo = (
  scriptParams: ScriptParams
): Record<
  ScriptIndex,
  { scriptCbor: string; scriptHash: string; scriptAddress: string }
> => {
  const allScriptIndices: ScriptIndex[] = [
    "Account",
    "AccountAppUnlock",
    "AccountUserUnlock",
    "AccountOracleValidator",
    "EmergencyToken",
    "EmergencyUnlock",
    "AccountOracleNFT",
  ];

  const scriptInfo: Record<
    ScriptIndex,
    { scriptCbor: string; scriptHash: string; scriptAddress: string }
  > = {} as any;

  allScriptIndices.forEach((scriptIndex) => {
    const scriptCbor = getScriptCbor(scriptIndex, scriptParams);
    const scriptHash = resolveScriptHash(scriptCbor, "V3");
    const scriptAddress = serializePlutusScript(
      { code: scriptCbor, version: "V3" },
      stakeCred,
      0,
      false
    ).address;
    scriptInfo[scriptIndex] = { scriptCbor, scriptHash, scriptAddress };
  });

  return scriptInfo;
};

export class MeshTx {
  address: string;
  params: ScriptParams = {
    accountOracleParamUtxoTxHash: "",
    accountOracleParamUtxoTxIndex: 0,
    ownerPubKeyHash: "",
  };
  oracle?: { address: string; utxoTxHash: string; utxoTxIndex: number };
  accountAddress?: string;

  constructor(public wallet: MeshWallet, params?: ScriptParams) {
    const address = this.wallet.getUsedAddresses()[0];
    this.address = address;
    const pubKeyHash = deserializeAddress(address).pubKeyHash;
    this.params.ownerPubKeyHash = pubKeyHash;
  }

  newTxBuilder = () => {
    return new MeshTxBuilder({
      fetcher: provider,
      evaluator: provider,
    });
  };

  newTx = async () => {
    const txBuilder = this.newTxBuilder();
    const utxos = await this.wallet.getUtxos();
    txBuilder.changeAddress(this.address).selectUtxosFrom(utxos);
    return txBuilder;
  };

  newValidationTx = async () => {
    const txBuilder = await this.newTx();
    const collateral = (await this.wallet.getCollateral())[0];
    txBuilder.txInCollateral(
      collateral.input.txHash,
      collateral.input.outputIndex,
      collateral.output.amount,
      collateral.output.address
    );
    return txBuilder;
  };

  prepare = async () => {
    const txBuilder = await this.newTx();
    const txHex = await txBuilder
      .txOut(this.address, [{ unit: "lovelace", quantity: "5000000" }])
      .txOut(this.address, [{ unit: "lovelace", quantity: "5000000" }])
      .txOut(this.address, [{ unit: "lovelace", quantity: "5000000" }])
      .txOut(this.address, [{ unit: "lovelace", quantity: "5000000" }])
      .txOut(this.address, [{ unit: "lovelace", quantity: "5000000" }])
      .complete();
    const singedTx = this.wallet.signTx(txHex);
    const txHash = await this.wallet.submitTx(singedTx);
    console.log("Prepare txHash:", txHash);
  };

  signAndSubmit = async (txHex: string, trace = "txHash: ") => {
    const signedTx = this.wallet.signTx(txHex, true);
    const txHash = await this.wallet.submitTx(signedTx);
    console.log(trace, txHash);
  };

  protected getWalletCollateral = async (): Promise<UTxO | undefined> => {
    if (this.wallet) {
      const utxos = await this.wallet.getCollateral();
      return utxos[0];
    }
    return undefined;
  };

  getWalletDappAddress = () => {
    if (this.wallet) {
      const usedAddresses = this.wallet.getUsedAddresses();
      if (usedAddresses.length > 0) {
        return usedAddresses[0];
      }
      const unusedAddresses = this.wallet.getUnusedAddresses();
      if (unusedAddresses.length > 0) {
        return unusedAddresses[0];
      }
    }
    return "";
  };

  protected getWalletInfoForTx = async () => {
    const utxos = await this.wallet?.getUtxos();
    const collateral = await this.getWalletCollateral();
    const walletAddress = this.getWalletDappAddress();
    if (!utxos || utxos?.length === 0) {
      throw new Error("No utxos found");
    }
    if (!collateral) {
      throw new Error("No collateral found");
    }
    if (!walletAddress) {
      throw new Error("No wallet address found");
    }
    return { utxos, collateral, walletAddress };
  };

  protected getAccountOracleDatum = () => {
    const accountOraclePolicyId = getScriptHash(
      "AccountOracleNFT",
      this.params
    );
    const accountOracleValidatorHash = getScriptHash(
      "AccountOracleValidator",
      this.params
    );
    const emergencyTokenPolicyId = getScriptHash("EmergencyToken", this.params);
    return mConStr0([
      accountOraclePolicyId,
      mScriptAddress(accountOracleValidatorHash, stakeCred),
      opsKey,
      emergencyTokenPolicyId,
      stopKey,
    ]);
  };
}

export const sleep = (second: number) =>
  new Promise((resolve) => setTimeout(resolve, second * 1000));
