import {
  deserializeAddress,
  MeshWallet,
  resolveScriptHash,
  serializeRewardAddress,
} from "@meshsdk/core";
import { MeshTx } from "../common";
import { getScriptCbor, ScriptParam } from "../config";

export class AccountTx extends MeshTx {
  constructor(wallet: MeshWallet, params?: ScriptParam) {
    super(wallet, params);
  }

  userUnlock = async () => {
    const ownPubKey = deserializeAddress(this.address).pubKeyHash;
    const withdrawScriptCbor = getScriptCbor("UserUnlock", this.params);
    const withdrawScriptHash = resolveScriptHash(withdrawScriptCbor, "V3");
    const withdrawScriptRewardAddress = serializeRewardAddress(
      withdrawScriptHash,
      true,
      0
    );

    const txBuilder = await this.newValidationTx();
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
