import {
  deserializeAddress,
  mConStr0,
  mConStr2,
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
    const { utxos, walletAddress, collateral } =
      await this.getWalletInfoForTx();
    const txBuilder = await this.newValidationTx();

    for (const utxo of accountUtxos) {
      txBuilder
        .spendingPlutusScriptV3()
        .txIn(
          utxo.input.txHash,
          utxo.input.outputIndex,
          utxo.output.amount,
          utxo.output.address
        )
        .txInRedeemerValue(mConStr0([]))
        .txInScript(getScriptCbor("Account", this.params))
        .txInInlineDatumPresent();
    }

    const userUnlockScriptHash = getScriptHash(
      "AccountUserUnlock",
      this.params
    );

    const userUnlockAddress = serializeRewardAddress(
      userUnlockScriptHash,
      true,
      0
    );

    await txBuilder
      .withdrawalPlutusScriptV3()
      .withdrawal(userUnlockAddress, "0")
      .withdrawalScript(getScriptCbor("AccountUserUnlock", this.params))
      .withdrawalRedeemerValue(mConStr0([]))
      .readOnlyTxInReference(refUtxo.txHash, refUtxo.outputIndex)
      .requiredSignerHash(this.params.ownerPubKeyHash!)
      .requiredSignerHash(opsKey)
      .txInCollateral(
        collateral.input.txHash,
        collateral.input.outputIndex,
        collateral.output.amount,
        collateral.output.address
      )
      .changeAddress(walletAddress)
      .selectUtxosFrom(utxos)
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
        .txInRedeemerValue(mConStr2([]))
        .txInScript(getScriptCbor("Account", this.params));
    }

    const txHex = await txBuilder
      .withdrawalPlutusScriptV3()
      .withdrawal(withdrawScriptRewardAddress, "0")
      .withdrawalScript(withdrawScriptCbor)
      .withdrawalRedeemerValue("")
      .requiredSignerHash(ownPubKey)
      .readOnlyTxInReference(
        this.oracle?.utxoTxHash!,
        this.oracle?.utxoTxIndex!
      )
      .complete();

    return txHex;
  };
}
