/**
 * 1. MaestroProvider
 * 2. Obtain pub key hash for hello world contract
 */

import { MaestroProvider } from "@meshsdk/core";

// const maestroApiKey = process.env.NEXT_PUBLIC_MAESTRO_API_KEY || "";
const maestroApiKey = "A41FZ8csuxpIZ8MVnlvU1jPsY43sAv4m";

const Module102 = () => {
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

  return (
    <div>
      <button
        className="bg-black text-white p-4 m-4 rounded-sm"
        onClick={() => testing()}>
        Testing
      </button>
    </div>
  );
};

export default Module102;
