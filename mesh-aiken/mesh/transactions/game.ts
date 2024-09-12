import {
  deserializeAddress,
  mConStr0,
  MeshWallet,
  NativeScript,
  serializeNativeScript,
  serializePlutusScript,
} from "@meshsdk/core";
import {
  ScriptParams,
  getScriptCbor,
  operationAddress,
  operationWallet,
  opsKey,
  provider,
  refUtxo,
  scriptParams,
} from "../config";
import { AccountTx } from "./account";

const gameScript = (participants: string[]): NativeScript => {
  const scripts: NativeScript[] = participants.map((participant) => ({
    type: "sig",
    keyHash: participant,
  }));
  return {
    type: "atLeast",
    required: 2,
    scripts: [...scripts, { type: "sig", keyHash: opsKey }],
  };
};

export class GameTx extends AccountTx {
  player2: MeshWallet;
  constructor(player1: MeshWallet, player2: MeshWallet) {
    super(player1, {
      ...scriptParams,
      ownerPubKeyHash: deserializeAddress(player1.getUsedAddresses()[0])
        .pubKeyHash,
    });
    this.player2 = player2;
  }

  play = async (playAmount: number) => {
    const {
      pubKey: player1PubKey,
      accountUtxos: player1Utxos,
      excessAmount: player1ExcessAmount,
      accountAddress: player1AccountAddress,
    } = await GameTx.getPlayerInfo(this.wallet, playAmount);
    const {
      pubKey: player2PubKey,
      accountUtxos: player2Utxos,
      excessAmount: player2ExcessAmount,
      accountAddress: player2AccountAddress,
    } = await GameTx.getPlayerInfo(this.player2, playAmount);

    const nativeScript = gameScript([player1PubKey, player2PubKey]);
    const scriptAddress = serializeNativeScript(nativeScript).address;

    const txBuilder = await this.newValidationTx();
    this.singleUserUnlock(txBuilder, this.wallet, player1Utxos);
    this.singleUserUnlock(txBuilder, this.player2, player2Utxos);

    txBuilder
      .txOut(scriptAddress!, [
        { unit: "lovelace", quantity: (playAmount * 2).toString() },
      ])
      .txOut(player1AccountAddress, [
        { unit: "lovelace", quantity: player1ExcessAmount.toString() },
      ])
      .txOutInlineDatumValue(mConStr0([]))
      .txOut(player2AccountAddress, [
        { unit: "lovelace", quantity: player2ExcessAmount.toString() },
      ])
      .txOutInlineDatumValue(mConStr0([]))
      .readOnlyTxInReference(refUtxo.txHash, refUtxo.outputIndex)
      .requiredSignerHash(opsKey);
    const txHex = await txBuilder.complete();
    return txHex;
  };

  end = async (winner: "player1" | "player2", fee = 1_000_000) => {
    const player1Address = this.wallet.getUsedAddresses()[0];
    const player2Address = this.player2.getUsedAddresses()[0];
    const player1PubKey = deserializeAddress(player1Address).pubKeyHash;
    const player2PubKey = deserializeAddress(player2Address).pubKeyHash;

    let winnerAddress = player1Address;
    let winnerPubKey = player1PubKey;
    let winnerUtxos = await this.wallet.getUtxos();
    if (winner === "player2") {
      winnerAddress = player2Address;
      winnerPubKey = player2PubKey;
      winnerUtxos = await this.player2.getUtxos();
    }

    const nativeScript = gameScript([player1PubKey, player2PubKey]);
    const { address: scriptAddress, scriptCbor } =
      serializeNativeScript(nativeScript);
    const gameUtxos = await provider.fetchAddressUTxOs(scriptAddress!);

    const txBuilder = this.newTxBuilder();
    for (const utxo of gameUtxos) {
      txBuilder
        .txIn(
          utxo.input.txHash,
          utxo.input.outputIndex,
          utxo.output.amount,
          utxo.output.address
        )
        .txInScript(scriptCbor!);
    }

    const txHex = await txBuilder
      .txOut(operationAddress, [{ unit: "lovelace", quantity: fee.toString() }])
      .changeAddress(winnerAddress)
      .readOnlyTxInReference(refUtxo.txHash, refUtxo.outputIndex)
      .requiredSignerHash(winnerPubKey)
      .requiredSignerHash(opsKey)
      .selectUtxosFrom(winnerUtxos)
      .complete();
    const operationKeySignedTx = operationWallet.signTx(txHex, true);
    return operationKeySignedTx;
  };

  static getPlayerInfo = async (player: MeshWallet, playAmount: number) => {
    const pubKey = deserializeAddress(player.getUsedAddresses()[0]).pubKeyHash;
    const params = {
      ...scriptParams,
      ownerPubKeyHash: pubKey,
    };
    const { accountUtxos, selectedAmount } = await AccountTx.getAccountUtxos(
      params,
      playAmount
    );
    const accountAddress = serializePlutusScript({
      code: getScriptCbor("Account", params),
      version: "V3",
    }).address;
    const excessAmount = selectedAmount - playAmount;
    return { pubKey, accountUtxos, excessAmount, accountAddress };
  };
}
