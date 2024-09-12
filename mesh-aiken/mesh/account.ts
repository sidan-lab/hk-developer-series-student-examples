import { newWallet, provider, scriptParams, sleep } from "./config";
import { AccountTx } from "./transactions/account";

const main = async () => {
  const deposit = async () => {
    const txHex = await account.deposit([
      10_000_000, 2_000_000, 2_000_000, 2_000_000, 2_000_000,
    ]);
    await account.signAndSubmit(txHex, "Deposit:");
  };

  const userUnlock = async () => {
    const { accountUtxos, selectedAmount } = await AccountTx.getAccountUtxos(
      scriptParams,
      15_000_000
    );
    console.log("Selected amount", selectedAmount);

    const txHex = await account.userUnlock(accountUtxos);
    await account.signAndSubmit(txHex, "User Unlock:");
  };

  const wallet = newWallet(Array(24).fill("summer"));
  // const wallet = newWallet(Array(24).fill("solution"));

  const account = new AccountTx(wallet, scriptParams);

  await deposit();
  await sleep(3);
  // await userUnlock();
};

main();
