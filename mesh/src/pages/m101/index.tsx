import {
  CardanoWallet,
  useAddress,
  useAssets,
  useLovelace,
  useWallet,
  useWalletList,
} from "@meshsdk/react";

/**
 * Prerequisites:
 * 1. Install Eternl Wallet
 * 2. Get Test ADA
 * 3. Set collateral
 *
 * Discuss
 * 1. CardanoWallet
 * 2. useWallet
 * 3. useWalletList
 * 4. useAssets
 * 5. useLovelace
 * 6. useAddress
 */

const Module101 = () => {
  const { connect, disconnect, connected, wallet } = useWallet();
  // console.log("wallet name", name);
  const assets = useAssets();
  console.log("assets", assets);
  const lovelace = useLovelace();
  console.log("lovelace", lovelace);
  const address = useAddress();
  console.log("address", address);

  const tryGettingBalance = async () => {
    if (connected) {
      const balance = await wallet.getBalance();
      console.log("balance", balance);
    }
  };

  const walletList = useWalletList();
  console.log("walletList", walletList);

  return (
    <div className="flex justify-center items-center p-20">
      <button
        className="bg-black text-white p-4 m-4 rounded-sm"
        onClick={() => connect("eternl")}>
        own connect
      </button>
      <button
        className="bg-black text-white p-4 m-4 rounded-sm"
        onClick={() => disconnect()}>
        own disconnect
      </button>
      <button
        className="bg-black text-white p-4 m-4 rounded-sm"
        onClick={() => tryGettingBalance()}>
        get balance
      </button>
      <CardanoWallet />
    </div>
  );
};

export default Module101;

{
  /* <CardanoWallet /> */
}
