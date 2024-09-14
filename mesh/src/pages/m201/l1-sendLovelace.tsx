import { MaestroProvider, MeshTxBuilder } from "@meshsdk/core";
import { CardanoWallet, useWallet } from "@meshsdk/react";

const maestroApiKey = "A41FZ8csuxpIZ8MVnlvU1jPsY43sAv4m";

const SendLovelace = () => {
  const { wallet } = useWallet();

  const maestro = new MaestroProvider({
    apiKey: maestroApiKey,
    network: "Preprod",
  });

  const testing = async () => {
    const address =
      "addr_test1qrgkr4jwau8wkk0ezf84yruv3uahzlksgxvd2nytzlnqft4x8s2nlvl23f82fut92a82jytnw4k7p0esygk2p626vjdqu58u9n";
    const utxos = await maestro.fetchAddressUTxOs(address);
    console.log("utxos", utxos);
  };

  const txBuilder = new MeshTxBuilder({
    fetcher: maestro,
    evaluator: maestro,
  });

  const sendLovelace = async () => {
    const utxos = await wallet.getUtxos();
    const address = await wallet.getChangeAddress();
    const txHex = await txBuilder
      .txOut(
        "addr_test1qpwcf3923zjpwy2q9rxyynk05p0sdc2kz0p0uwupg784w6mt9xwelhz3ajwucn24eetyaxly7gahn3pqn0safv92yatqqxzd75",
        [{ unit: "lovelace", quantity: "2000000" }]
      )
      .changeAddress(address)
      .selectUtxosFrom(utxos)
      .complete();
    const signedTx = await wallet.signTx(txHex);
    const txHash = await wallet.submitTx(signedTx);
    console.log("txHash", txHash);
  };

  return (
    <div>
      <button
        className="bg-black text-white p-4 m-4 rounded-sm"
        onClick={() => testing()}>
        Testing
      </button>
      <button
        className="bg-black text-white p-4 m-4 rounded-sm"
        onClick={() => sendLovelace()}>
        Send Lovelace
      </button>
      <CardanoWallet />
    </div>
  );
};

export default SendLovelace;
