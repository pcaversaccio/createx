import * as fs from "fs";
import path from "path";
import hre from "hardhat";

import signedTx from "./presigned-createx-deployment-transaction/signed_serialised_transaction.json";

// Colour codes for terminal prints
const RESET = "\x1b[0m";
const GREEN = "\x1b[32m";
const RED = "\x1b[31m";

const dir = path.join(__dirname, "broadcasted-createx-deployment-transaction");

export async function execute() {
  try {
    if (hre.network.config.url == null) {
      throw new Error("No RPC URL configured.");
    }
    const rpc = hre.network.config.url;
    if (typeof rpc !== "string") {
      throw new Error("Invalid RPC URL configured.");
    }

    const provider = new hre.ethers.JsonRpcProvider(rpc);
    // Send the transaction
    const tx = await provider.broadcastTransaction(signedTx);
    console.log("Transaction hash: " + `${GREEN}${tx.hash}${RESET}`);
    const transactionReceipt = await tx.wait();

    // Save the transaction receipt in a JSON file
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir);
    }
    const saveDir = path.normalize(path.join(dir, "transaction_receipt.json"));
    fs.writeFileSync(saveDir, JSON.stringify(transactionReceipt));

    console.log(
      `\n${GREEN}Transaction has been successfully broadcasted!${RESET}`,
    );
    console.log(`Transaction details written to: ${GREEN}${saveDir}${RESET}\n`);
  } catch (err) {
    // Save the transaction error in a JSON file
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir);
    }
    const saveDir = path.normalize(path.join(dir, "transaction_error.json"));
    fs.writeFileSync(saveDir, JSON.stringify(err));

    console.log(`\n${RED}Transaction broadcasting failed!${RESET}`);
    console.log(`Error details written to: ${RED}${saveDir}${RESET}\n`);
  }
}

execute().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
