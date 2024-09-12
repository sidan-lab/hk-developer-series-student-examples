import {
  deserializeAddress,
  mConStr0,
  mConStr2,
  MeshTxBuilder,
  MeshWallet,
  resolveScriptHash,
  serializePlutusScript,
  serializeRewardAddress,
  UTxO,
} from "@meshsdk/core";
import { getScriptHash, MeshTx } from "../config/common";
import {
  getScriptCbor,
  refUtxo,
  ScriptParams,
  opsKey,
  operationWallet,
  provider,
} from "../config";

export class AccountTx extends MeshTx {
  constructor(wallet: MeshWallet, params: ScriptParams) {
    super(wallet, params);
    this.accountAddress = serializePlutusScript({
      code: getScriptCbor("Account", params),
      version: "V3",
    }).address;
  }

  deposit = async (depositLovelaceAmounts: number[]) => {
    const txBuilder = await this.newTx();
    for (const amount of depositLovelaceAmounts) {
      txBuilder
        .txOut(this.accountAddress!, [
          {
            unit: "lovelace",
            quantity: amount.toString(),
          },
        ])
        .txOutInlineDatumValue(mConStr0([]));
    }

    const txHex = await txBuilder.complete();
    return txHex;
  };

  userUnlock = async (accountUtxos: UTxO[]) => {
    const txBuilder = await this.newValidationTx();
    this.singleUserUnlock(txBuilder, this.wallet, accountUtxos);

    await txBuilder
      .readOnlyTxInReference(refUtxo.txHash, refUtxo.outputIndex)
      .requiredSignerHash(opsKey)
      .complete();

    const partialSignedTx = operationWallet.signTx(txBuilder.txHex, true);
    return partialSignedTx;
  };

  appUnlockCombineIntoOne = async (accountUtxos: UTxO[]) => {
    const ownPubKey = deserializeAddress(this.address).pubKeyHash;
    const withdrawScriptCbor = getScriptCbor("AccountAppUnlock", this.params);
    const withdrawScriptHash = resolveScriptHash(withdrawScriptCbor, "V3");
    const withdrawScriptRewardAddress = serializeRewardAddress(
      withdrawScriptHash,
      true,
      0
    );

    const txBuilder = await this.newValidationTx();

    const txHex = await txBuilder
      .readOnlyTxInReference(
        this.oracle?.utxoTxHash!,
        this.oracle?.utxoTxIndex!
      )
      .complete();

    return txHex;
  };

  protected singleUserUnlock = async (
    txBuilder: MeshTxBuilder,
    wallet: MeshWallet,
    accountUtxos: UTxO[]
  ) => {
    const walletAddress = wallet.getUsedAddresses()[0];
    const params = {
      ...this.params,
      ownerPubKeyHash: deserializeAddress(walletAddress).pubKeyHash,
    };
    const ownPubKey = deserializeAddress(walletAddress).pubKeyHash;
    for (const utxo of accountUtxos) {
      txBuilder
        .spendingPlutusScriptV3()
        .txIn(
          utxo.input.txHash,
          utxo.input.outputIndex,
          utxo.output.amount,
          utxo.output.address
        )
        .txInInlineDatumPresent()
        .txInRedeemerValue(mConStr0([]))
        .txInScript(getScriptCbor("Account", params));
    }

    const userUnlockScriptCbor = getScriptCbor("AccountUserUnlock", params);
    const userUnlockScriptHash = resolveScriptHash(userUnlockScriptCbor, "V3");

    const userUnlockAddress = serializeRewardAddress(
      userUnlockScriptHash,
      true,
      0
    );

    txBuilder
      .withdrawalPlutusScriptV3()
      .withdrawal(userUnlockAddress, "0")
      .withdrawalScript(userUnlockScriptCbor)
      .withdrawalRedeemerValue("", "Mesh", { steps: 40000000, mem: 200000 })
      .requiredSignerHash(ownPubKey);
  };

  static async getAccountUtxos(params: ScriptParams, lovelaceAmount = -1) {
    const accountAddress = serializePlutusScript({
      code: getScriptCbor("Account", params),
      version: "V3",
    }).address;
    const accountUtxos = await provider.fetchAddressUTxOs(accountAddress);

    let selectedAmount = 0;
    for (let i = 0; i < accountUtxos.length; i++) {
      selectedAmount += Number(
        accountUtxos[i].output.amount.find((a) => a.unit === "lovelace")!
          .quantity
      );
      if (selectedAmount >= lovelaceAmount && lovelaceAmount >= 0) {
        accountUtxos.splice(i + 1);
        break;
      }
    }

    if (selectedAmount < lovelaceAmount) {
      throw new Error("Insufficient account utxos funds");
    }

    console.log("accountUtxos:", accountUtxos);
    return { accountUtxos, selectedAmount };
  }
}
