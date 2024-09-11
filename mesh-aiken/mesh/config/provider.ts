import { YaciProvider } from "@meshsdk/core";
import axios from "axios";

const yaciBaseUrl = process.env.YACI_BASE_URL || "https://yaci-node.meshjs.dev";

export class MeshYaciProvider extends YaciProvider {
  constructor() {
    super(`${yaciBaseUrl}/api/v1`);
  }

  fundWallet = async (walletAddress: string, adaAmount: number) => {
    const res = await axios.post(`${yaciBaseUrl}/admin/topup`, {
      wallet_address: walletAddress,
      ada_amount: adaAmount,
    });
    return res.data;
  };

  getGenesis = async () => {
    const res = await axios.get(`${yaciBaseUrl}/admin/genesis`);
    return res.data;
  };
}

export const provider = new MeshYaciProvider();
