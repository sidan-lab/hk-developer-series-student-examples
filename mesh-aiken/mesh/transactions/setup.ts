import { MeshWallet } from "@meshsdk/core";
import { MeshTx } from "../common";

export class SetupContract extends MeshTx {
  constructor(wallet: MeshWallet) {
    super(wallet);
  }

  mintOracle = async () => {
    const txBuilder = await this.newValidationTx();
    const txHex = await txBuilder
      .mintPlutusScriptV3()
      .mint("1", "oracle", "")
      .mintRedeemerValue("")
      .complete();

    return txHex;
  };
}
