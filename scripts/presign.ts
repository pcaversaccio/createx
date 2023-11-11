import * as fs from "fs";
import path from "path";
import hre from "hardhat";

import { ethMainnetUrl, accounts } from "../hardhat.config";

const RESET = "\x1b[0m";
const GREEN = "\x1b[32m";
const RED = "\x1b[31m";

const dir = path.join(__dirname, "presigned-createx-deployment-transaction");

export async function presign() {
  try {
    if (!Array.isArray(accounts)) {
      throw new Error("No private key configured.");
    }
    const privateKey = accounts[0];
    if (typeof privateKey !== "string") {
      throw new Error("Invalid private key configured.");
    }

    if (ethMainnetUrl == null) {
      throw new Error("No RPC URL configured.");
    }
    if (typeof ethMainnetUrl !== "string") {
      throw new Error("Invalid RPC URL configured.");
    }

    const provider = new hre.ethers.JsonRpcProvider(ethMainnetUrl);
    const wallet = new hre.ethers.Wallet(privateKey, provider);

    console.log(
      "Using wallet address: " + `${GREEN}${wallet.address}${RESET}\n`,
    );

    const CreateX = await hre.ethers.getContractFactory("CreateX");
    const initCode = await CreateX.getDeployTransaction();

    ////////////////////////////////////////////////
    // Prepare the replayable transaction payload //
    ////////////////////////////////////////////////
    const tx = new hre.ethers.Transaction();
    tx.to = null; // A contract creation transaction has a `to` address of `null`
    tx.gasLimit = 3_000_000; // A normal deployment currently costs 2,543,595 gas. We can later add different `gasLimit` levels for the final presigned transaction
    tx.gasPrice = hre.ethers.parseUnits("100", "gwei"); // A gas price of 100 gwei
    tx.data = initCode.data; // Contract creation bytecode
    tx.chainId = 0; // Disable EIP-155 functionality (https://github.com/ethers-io/ethers.js/blob/bbcfb5f6b88800b8ef068e4a2923675503320e33/src.ts/transaction/transaction.ts#L168)
    tx.nonce = 0; // It must be the first transaction of the deployer account
    tx.type = 0; // Set to legacy transaction type 0

    // Sign the transaction
    const signedTx = hre.ethers.Transaction.from(
      await wallet.signTransaction(tx),
    );

    // Save the serialised signed transaction in a JSON file
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir);
    }
    const saveDir = path.normalize(
      path.join(dir, "signed_serialised_transaction.json"),
    );
    fs.writeFileSync(saveDir, JSON.stringify(signedTx.serialized));

    console.log(`${GREEN}Signing attempt has been successful!${RESET}`);
    console.log(
      `Serialised signed transaction written to: ${GREEN}${saveDir}${RESET}\n`,
    );

    // Print the raw transaction details
    console.log("Raw Transaction Details", "\n");
    console.log("----------------------------------", "\n");
    console.log("- from: " + `${GREEN}${signedTx.from}${RESET}`);
    console.log("- publicKey: " + `${GREEN}${signedTx.fromPublicKey}${RESET}`);
    console.log("- gasLimit: " + `${GREEN}${signedTx.gasLimit}${RESET}`);
    console.log("- gasPrice: " + `${GREEN}${signedTx.gasPrice}${RESET}`);
    console.log("- data: " + `${GREEN}${signedTx.data}${RESET}`);
    console.log("- nonce: " + `${GREEN}${signedTx.nonce}${RESET}`);
    console.log("- to: " + `${GREEN}${signedTx.to}${RESET}`);
    console.log("- type: " + `${GREEN}${signedTx.type}${RESET}`);
    console.log("- typeName: " + `${GREEN}${signedTx.typeName}${RESET}`);
    console.log("- chainId: " + `${GREEN}${signedTx.chainId}${RESET}`);
    console.log("- serialised: " + `${GREEN}${signedTx.serialized}${RESET}`); // We use this output to broadcast the contract creation transaction
  } catch (err) {
    // Save the signing attempt error in a JSON file
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir);
    }
    const saveDir = path.normalize(
      path.join(dir, "signing_attempt_error.json"),
    );
    fs.writeFileSync(saveDir, JSON.stringify(err));

    console.log(`${RED}Signing attempt failed!${RESET}`);
    console.log(`Error details written to: ${RED}${saveDir}${RESET}\n`);
  }
}

presign().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
