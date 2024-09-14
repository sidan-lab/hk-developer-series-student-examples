import { resolveScriptHash, stringToHex } from "@meshsdk/core";
import { applyCborEncoding } from "@meshsdk/core-csl";
import { MaestroProvider, MeshTxBuilder } from "@meshsdk/core";
import { CardanoWallet, useWallet } from "@meshsdk/react";

const maestroApiKey = "A41FZ8csuxpIZ8MVnlvU1jPsY43sAv4m";

/**
 * 1. Mint Native tokens
 * 2. Mint one time minting policy
 */

const alwaysSucceedMintingRawScript =
  "5850010100323232323225333002323232323253330073370e900018041baa0011324a26eb8c028c024dd50008b1804980500118040009804001180300098021baa00114984d9595cd2ab9d5573cae855d11";

const scriptCbor = applyCborEncoding(alwaysSucceedMintingRawScript);

const MintPlutusToken = () => {
  const { wallet } = useWallet();

  const maestro = new MaestroProvider({
    apiKey: maestroApiKey,
    network: "Preprod",
  });

  const policyId = resolveScriptHash(scriptCbor, "V3");
  const mintAlwaysSucceed = async () => {
    const txBuilder = new MeshTxBuilder({
      fetcher: maestro,
      evaluator: maestro,
    });

    const utxso = await wallet.getUtxos();
    const address = await wallet.getChangeAddress();
    const collateral = (await wallet.getCollateral())[0];

    const txHex = await txBuilder
      .mintPlutusScriptV3()
      .mint("1", policyId, stringToHex("Hinson token"))
      .mintingScript(scriptCbor)
      .mintRedeemerValue("")
      .changeAddress(address)
      .selectUtxosFrom(utxso)
      .txInCollateral(
        collateral?.input.txHash!,
        collateral?.input.outputIndex!,
        collateral?.output.amount,
        collateral?.output.address
      )
      .complete();

    const signedTx = await wallet.signTx(txHex);
    const txHash = await wallet.submitTx(signedTx);
    console.log("txHash", txHash);
  };

  return (
    <div>
      <button
        className="bg-black text-white p-4 m-4 rounded-sm"
        onClick={() => mintAlwaysSucceed()}>
        mintAlwaysSucceed
      </button>
      <CardanoWallet />
    </div>
  );
};

export default MintPlutusToken;
