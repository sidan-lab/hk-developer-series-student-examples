import {
  deserializeAddress,
  mConStr0,
  mConStr2,
  MeshWallet,
  resolveScriptHash,
  serializeRewardAddress,
  UTxO,
} from "@meshsdk/core";
import { MeshTx } from "../common";
import { getScriptCbor, ScriptParam } from "../config";

export class AccountTx extends MeshTx {
  constructor(wallet: MeshWallet, params?: ScriptParam) {
    super(wallet, params);
  }

  deposit = async (depositLovelaceAmounts: number[]) => {
    const accountScriptCbor = getScriptCbor("Account", this.params);
    const accountScriptHash = resolveScriptHash(accountScriptCbor, "V3");
    const accountRewardAddress = serializeRewardAddress(
      accountScriptHash,
      true,
      0
    );

    const txBuilder = await this.newTx();
    for (const amount of depositLovelaceAmounts) {
      txBuilder
        .txOut(accountRewardAddress, [
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
    const ownPubKey = deserializeAddress(this.address).pubKeyHash;
    const withdrawScriptCbor = getScriptCbor("UserUnlock", this.params);
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
        .txInRedeemerValue(mConStr0([]))
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

  appUnlockCombineIntoOne = async (accountUtxos: UTxO[]) => {
    const ownPubKey = deserializeAddress(this.address).pubKeyHash;
    const withdrawScriptCbor = getScriptCbor("UserUnlock", this.params);
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
