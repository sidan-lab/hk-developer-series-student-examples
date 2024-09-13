import { CardanoWallet } from "@meshsdk/react";

/**
 * Prerequisites:
 * 1. Install Eternl Wallet
 * 2. Get Test ADA
 * 3. Set collateral
 *
 * Discss
 * 1. CardanoWallet
 * 2. useWallet
 * 3. useWalletList
 * 4. useAssets
 * 5. useLovelace
 * 6. useAddress
 */

const Module101 = () => {
  return (
    <div className="flex justify-center items-center p-20">
      <CardanoWallet />
    </div>
  );
};

export default Module101;
