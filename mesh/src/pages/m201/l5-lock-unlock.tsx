/**
 * Use hello world contract
 */

import {
  deserializeAddress,
  MaestroProvider,
  mConStr0,
  mConStr1,
  MeshTxBuilder,
  mPubKeyAddress,
  serializePlutusScript,
} from "@meshsdk/core";
import { applyParamsToScript } from "@meshsdk/core-csl";
import { CardanoWallet, useWallet } from "@meshsdk/react";

const maestroApiKey = "A41FZ8csuxpIZ8MVnlvU1jPsY43sAv4m";
const maestro = new MaestroProvider({
  apiKey: maestroApiKey,
  network: "Preprod",
});
const rawScript =
  "5906be01010032323232323232223225333005323232323253323300b3001300c37540042646464646464a66602260060022a66602860266ea8024540085854ccc044c01c00454ccc050c04cdd50048a8010b0b18089baa0081533300f30013010375400426464a64666024600860266ea80284c94ccc04cc014c050dd5000899299980b980d1991191980080080191299980d8008a5eb804c8c94ccc068cdd79805180e1baa3007301c375400400a26603c00466008008002266008008002603e004603a0026eb0c010c058dd50071802180b1baa3001301637546032602c6ea80084c8c8c8c8c94ccc064cc008cc00cdd61802180d9baa0133009301b3754014600a6eb4c018c06cdd500508008a5033001330023758600660346ea804805cc010cdc199b82375a600a60346ea802405520a09c01223233001001323300100100322533301f00114bd7009919991119198008008019129998128008801899198139ba733027375200c6604e60480026604e604a00297ae03300300330290023027001375c603c0026eacc07c004cc00c00cc08c008c084004894ccc078004528899299980e1919b89375a6010002664464a666040602c60426ea8004520001375a604a60446ea8004c94ccc080c058c084dd50008a6103d87a8000132330010013756604c60466ea8008894ccc094004530103d87a80001323232325333026337220100042a66604c66e3c0200084c054cc0a8dd4000a5eb80530103d87a8000133006006003375a604e0066eb8c094008c0a4008c09c004c8cc004004024894ccc0900045300103d87a80001323232325333025337220100042a66604a66e3c0200084c050cc0a4dd3000a5eb80530103d87a80001330060060033756604c0066eb8c090008c0a0008c098004dd718068009bae300a001375860420042660060060022940c08400488c8cc00400400c894ccc07400452f5bded8c026644a66603866ebcc030c078dd50010028991998008008011bab300a301f3754006444a6660440042002264666008008604c0066644646600200200a44a66604e00226605066ec0dd48021ba60034bd6f7b630099191919299981419b9000800213302c337606ea4020dd30038028a99981419b8f0080021325333029301b302a375400226605a66ec0dd4804981718159baa0010041004325333029533302c00114a22940530103d87a8000130183302d374c00297ae032333001001008002222533302e0021001132333004004303200333223233001001005225333033001133034337606ea4010dd4001a5eb7bdb1804c8c8c8c94ccc0d0cdc800400109981c19bb037520106ea001c01454ccc0d0cdc7804001099299981a9813981b1baa001133039337606ea4024c0e8c0dcdd5000802080219299981a98138008a60103d87a80001302433039375000297ae03370000e00226607066ec0dd48011ba800133006006003375a606a0066eb8c0cc008c0dc008c0d4004dd718168009bad302e001303000213302c337606ea4008dd3000998030030019bab3029003375c604e004605600460520026eb8c084004dd5981100098120010800980f8009980100118100009180d980e180e0009299980a98038008a5eb7bdb1804c8c8cc0040052f5bded8c044a66603600226603866ec13001014000374c00697adef6c60132323232533301c33720910100002133020337609801014000374c00e00a2a66603866e3d22100002133020337609801014000374c00e00626604066ec0dd48011ba6001330060060033756603a0066eb8c06c008c07c008c074004c8cc0040052f5bded8c044a66603400226603666ec13001014000375000697adef6c60132323232533301b3372091010000213301f337609801014000375000e00a2a66603666e3d2210000213301f337609801014000375000e00626603e66ec0dd48011ba800133006006003375a60380066eb8c068008c078008c070004588c064c06800458c8cc004004dd61801980a9baa00d22533301700114c0103d87a80001323253330163375e600c60306ea80080284c014cc0680092f5c02660080080026036004603200226464a666028600c602a6ea80044c8c8cc004004010894ccc068004528099299980c19b8f375c603a00400829444cc00c00c004c074004dd7180c980b1baa0011632533301430063015375400226006660306032602c6ea80052f5c02980103d87a80003003301537546006602a6ea8010dd6180b980c180c180c180c180c180c180c180c180a1baa00c374a90001180b000980a18089baa00216370e900018091809801180880098069baa002370e90010b1807180780118068009806801180580098039baa00114984d958dd6800ab9a5573aaae7955cfaba05742ae881";

const scriptCbor = (ownerAddress: string, feePercentageBasisPoint: number) => {
  const { pubKeyHash, stakeCredentialHash } = deserializeAddress(ownerAddress);
  return applyParamsToScript(rawScript, [
    mPubKeyAddress(pubKeyHash, stakeCredentialHash),
    feePercentageBasisPoint,
  ]);
};

const LockUnlock = () => {
  const { wallet } = useWallet();

  const listingAsset = async (
    policyIdToList: string,
    tokenNameToList: string
  ) => {
    const txBuilder = new MeshTxBuilder({
      fetcher: maestro,
      evaluator: maestro,
    });
    const walletAddress = (await wallet.getUsedAddresses())[0]!;
    const { pubKeyHash, stakeCredentialHash } =
      deserializeAddress(walletAddress);

    const scriptAddress = serializePlutusScript({
      code: scriptCbor(walletAddress, 500),
      version: "V3",
    }).address;

    const utxos = await wallet.getUtxos();

    const txHex = await txBuilder
      .txOut(scriptAddress, [
        { unit: policyIdToList + tokenNameToList, quantity: "1" },
      ])
      .txOutInlineDatumValue(
        mConStr0([
          mPubKeyAddress(pubKeyHash, stakeCredentialHash),
          100000000,
          policyIdToList,
          tokenNameToList,
        ])
      )
      .changeAddress(walletAddress)
      .selectUtxosFrom(utxos)
      .complete();

    const signedTx = await wallet.signTx(txHex);
    const txHash = await wallet.submitTx(signedTx);
    console.log("txHash", txHash);
  };

  const closeSelling = async () => {
    const listingTxHash =
      "86bb203c8b6a23992ee62ecbfd85a60a356d04a6323b0dc747e3fc01410f5905";

    const txBuilder = new MeshTxBuilder({
      fetcher: maestro,
      evaluator: maestro,
    });
    const walletAddress = (await wallet.getUsedAddresses())[0]!;
    const { pubKeyHash, stakeCredentialHash } =
      deserializeAddress(walletAddress);

    const scriptAddress = serializePlutusScript({
      code: scriptCbor(walletAddress, 500),
      version: "V3",
    }).address;

    const utxos = await wallet.getUtxos();
    const collateral = (await wallet.getCollateral())[0];

    const txHex = await txBuilder
      .spendingPlutusScriptV3()
      .txIn(listingTxHash, 0)
      .txInScript(scriptCbor(walletAddress, 500))
      .txInInlineDatumPresent()
      .txInRedeemerValue(mConStr1([]))
      .requiredSignerHash(pubKeyHash)
      .changeAddress(walletAddress)
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
        onClick={() =>
          listingAsset(
            "71fe8f5705f48860de917b6b402d32f8239503f3cfac85db51dbe83e",
            "4d657368546f6b656e"
          )
        }>
        mintAlwaysSucceed
      </button>
      <button
        className="bg-black text-white p-4 m-4 rounded-sm"
        onClick={() => closeSelling()}>
        mintAlwaysSucceed
      </button>
      <CardanoWallet />
    </div>
  );
};

export default LockUnlock;
