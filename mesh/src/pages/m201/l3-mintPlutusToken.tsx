import { mConStr0, resolveScriptHash, stringToHex } from "@meshsdk/core";
import { applyParamsToScript, applyCborEncoding } from "@meshsdk/core-csl";
import { MaestroProvider, MeshTxBuilder } from "@meshsdk/core";
import { CardanoWallet, useWallet } from "@meshsdk/react";

const maestroApiKey = "A41FZ8csuxpIZ8MVnlvU1jPsY43sAv4m";

/**
 * 1. Mint Native tokens
 * 2. Mint one time minting policy
 */

// const alwaysSucceedMintingRawScript =
//   "5850010100323232323225333002323232323253330073370e900018041baa0011324a26eb8c028c024dd50008b1804980500118040009804001180300098021baa00114984d9595cd2ab9d5573cae855d11";
const oneTimeMintingPolicyRawScript =
  "59019e0101003232323232323222533300332323232325332330093001300a37540042646464a66601860080022a66601e601c6ea8018540085854ccc030cdc3a40040022a66601e601c6ea8018540085858c030dd50028992999805980198061baa0051533300b3003300c375464660020026eb0c008c038dd50041129998080008a60103d87a800013232533300f3375e600a60226ea80080384cdd2a40006602600497ae01330040040013014002301200114a229404c8cc004004c8cc004004dd59809180998099809980998079baa00922533301100114bd70099199911191980080080191299980b80088018991980c9ba733019375200c66032602c00266032602e00297ae033003003301b0023019001375c60200026eacc044004cc00c00cc054008c04c004894ccc040004528899299980719299980799b8f375c600a00200c266e20dd6980a180a980a800a40002944dd618098010998018018008a50301300123010001375c601c60166ea8008dc3a40002c6018601a004601600260160046012002600a6ea8004526136565734aae7555cf2ab9f5740ae855d101";

const scriptCbor = (txHash: string, txIndex: number) =>
  applyParamsToScript(oneTimeMintingPolicyRawScript, [
    mConStr0([txHash, txIndex]),
  ]);
// const scriptCbor = applyCborEncoding(alwaysSucceedMintingRawScript);

const MintPlutusToken = () => {
  const { wallet } = useWallet();

  const maestro = new MaestroProvider({
    apiKey: maestroApiKey,
    network: "Preprod",
  });

  const mintOneTimePolicy = async () => {
    const txBuilder = new MeshTxBuilder({
      fetcher: maestro,
      evaluator: maestro,
    });

    const utxos = await wallet.getUtxos();
    const firstUtxo = utxos[0]!;

    const address = await wallet.getChangeAddress();
    const collateral = (await wallet.getCollateral())[0];

    const policyCbor = scriptCbor(
      firstUtxo.input.txHash,
      firstUtxo.input.outputIndex
    );
    const policyId = resolveScriptHash(policyCbor, "V3");
    const tokenName = stringToHex("First one time minting policy!");

    const txHex = await txBuilder
      .txIn(firstUtxo.input.txHash, firstUtxo.input.outputIndex)
      .mintPlutusScriptV3()
      .mint("1", policyId, tokenName)
      .mintingScript(policyCbor)
      .mintRedeemerValue(mConStr0([]))
      .txOut(address, [
        { unit: policyId + tokenName, quantity: "1" },
        { unit: "lovelace", quantity: "2000000" },
      ])
      .changeAddress(address)
      .selectUtxosFrom(utxos)
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
        onClick={() => mintOneTimePolicy()}>
        mintAlwaysSucceed
      </button>
      <CardanoWallet />
    </div>
  );
};

export default MintPlutusToken;
