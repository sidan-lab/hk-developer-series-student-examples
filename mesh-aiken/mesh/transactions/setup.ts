import {
  conStr0,
  mConStr0,
  MeshWallet,
  policyId,
  pubKeyHash,
  resolveScriptHash,
  resolveTxHash,
  scriptAddress,
  serializePlutusScript,
  serializeRewardAddress,
} from "@meshsdk/core";
import { MeshTx } from "../common";
import { getScriptCbor, getScriptHash, ScriptParam } from "../config/constant";
import { OracleDatum } from "../config/types";
import { operationKey, stopKey } from "../config/keys";

export class SetupContract extends MeshTx {
  constructor(wallet: MeshWallet, params?: ScriptParam) {
    super(wallet, params);
  }

  registerAllStakeCerts = async () => {
    const appUnlock = getScriptCbor("AppUnlock", this.params);
    const appUnlockHash = resolveScriptHash(appUnlock, "V3");
    const appUnlockRewardAddress = serializeRewardAddress(
      appUnlockHash,
      true,
      0
    );
    const userUnlock = getScriptCbor("UserUnlock", this.params);
    const userUnlockHash = resolveScriptHash(userUnlock, "V3");
    const userUnlockRewardAddress = serializeRewardAddress(
      userUnlockHash,
      true,
      0
    );
    const txBuilder = await this.newValidationTx();
    const txHex = await txBuilder
      .registerStakeCertificate(appUnlockRewardAddress)
      .registerStakeCertificate(userUnlockRewardAddress)
      .complete();

    return txHex;
  };

  mintOracleNFT = async () => {
    const utxos = await this.wallet.getUtxos();
    const collateral = (await this.wallet.getCollateral())[0];
    const paramUtxo = utxos[0];
    this.params.oracleTxHash = paramUtxo.input.txHash;
    this.params.oracleTxIndex = paramUtxo.input.outputIndex;
    this.accountAddress = serializePlutusScript({
      code: getScriptCbor("Account", this.params),
      version: "V3",
    }).address;
    console.log("Application initialized with parameters:", this.params);

    const script = getScriptCbor("OracleNFT", this.params);
    const policyId = resolveScriptHash(script, "V3");

    const txBuilder = this.newTxBuilder();
    const txHex = await txBuilder
      .txIn(
        paramUtxo.input.txHash,
        paramUtxo.input.outputIndex,
        paramUtxo.output.amount,
        paramUtxo.output.address
      )
      .mintPlutusScriptV3()
      .mint("1", policyId, "")
      .mintRedeemerValue(mConStr0([]))
      .mintingScript(script)
      .txInCollateral(
        collateral.input.txHash,
        collateral.input.outputIndex,
        collateral.output.amount,
        collateral.output.address
      )
      .changeAddress(this.address)
      .complete();

    return txHex;
  };

  initOracle = async () => {
    const oraclePolicyId = getScriptHash("OracleNFT", this.params);
    const oracleScriptHash = resolveScriptHash(
      getScriptCbor("AccountOracle", this.params),
      "V3"
    );
    const emergencyTokenPolicyId = getScriptHash("EmergencyToken", this.params);
    const initOracleDatum: OracleDatum = conStr0([
      policyId(oraclePolicyId),
      scriptAddress(oracleScriptHash),
      pubKeyHash(operationKey),
      policyId(emergencyTokenPolicyId),
      pubKeyHash(stopKey),
    ]);

    const accountOracle = getScriptCbor("AccountOracle", this.params);
    const oracleAddress = serializePlutusScript({
      code: accountOracle,
      version: "V3",
    }).address;

    const txBuilder = await this.newTx();
    const txHex = await txBuilder
      .txOut(oracleAddress, [{ unit: oraclePolicyId, quantity: "1" }])
      .txOutInlineDatumValue(initOracleDatum, "JSON")
      .complete();

    this.oracle = {
      address: oracleAddress,
      utxoTxHash: resolveTxHash(txHex),
      utxoTxIndex: 0,
    };

    return txHex;
  };
}
