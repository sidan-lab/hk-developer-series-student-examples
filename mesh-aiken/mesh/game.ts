import { newWallet, provider, sleep } from "./config";
import { GameTx } from "./transactions/game";

const main = async () => {
  const play = async () => {
    const txHex = await game.play(2_000_000);
    const player1SignedTx = player1.signTx(txHex, true);
    const signedTx = player2.signTx(player1SignedTx, true);
    const txHash = await provider.submitTx(signedTx);
    console.log("Play txHash:", txHash);
  };
  const end = async () => {
    const txHex = await game.end("player1");
    const signedTx = player1.signTx(txHex, true);
    const txHash = await provider.submitTx(signedTx);
    console.log("End txHash:", txHash);
  };

  const player1 = newWallet(Array(24).fill("summer"));
  const player2 = newWallet(Array(24).fill("solution"));

  const game = new GameTx(player1, player2);

  // await play();
  // await sleep(3);
  await end();
};

main();
