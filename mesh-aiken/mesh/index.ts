import { newWallet, provider, sleep } from "./config";
import { SetupContract } from "./transactions";

const testTx = async () => {
  const init = async () => {
    const address = wallet.getUsedAddresses()[0];
    // await provider.fundWallet(address, 1000);
    // await sleep(1);
    // await setup.prepare();
    // await sleep(1);
    // const mintTxHex = await setup.mintOracleNFT();
    // await setup.signAndSubmit(mintTxHex, "Mint Oracle:");
    // await sleep(1);
    // const sendTxHex = await setup.initOracle();
    // await setup.signAndSubmit(sendTxHex, "Send Oracle:");
    // await sleep(1);
    const registerCertTxHex = await setup.registerAllStakeCerts();
    await setup.signAndSubmit(registerCertTxHex, "Register Stake Certs:");
    await sleep(1);
  };

  console.log("Start testing Aiken PlutusV3 + Mesh on Yaci");

  const wallet = newWallet(Array(24).fill("summer"));
  // const wallet = newWallet(Array(24).fill("solution"));
  const setup = new SetupContract(wallet);
  await init();
};

testTx();
