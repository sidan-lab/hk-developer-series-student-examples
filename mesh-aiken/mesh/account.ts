import { newWallet, provider, scriptParams, sleep } from "./config";
import { AccountTx } from "./transactions/account";

const main = async () => {
  const deposit = async () => {
    const txHex = await account.deposit([1000000]);
    await account.signAndSubmit(txHex, "Deposit:");
  };

  const userUnlock = async () => {
    const accountUtxos = await provider.fetchAddressUTxOs(
      account.accountAddress!
    );
    const txHex = await account.userUnlock(accountUtxos);
    await account.signAndSubmit(txHex, "User Unlock:");
  };

  const wallet = newWallet([
    "board",
    "minor",
    "need",
    "panda",
    "end",
    "drastic",
    "amazing",
    "tree",
    "boost",
    "wolf",
    "host",
    "renew",
    "metal",
    "leader",
    "follow",
    "planet",
    "aunt",
    "brisk",
    "grab",
    "husband",
    "picnic",
    "cruise",
    "patrol",
    "pact",
  ]);

  const account = new AccountTx(wallet, scriptParams);

  await deposit();
  sleep(1);
  await userUnlock();
};

main();
