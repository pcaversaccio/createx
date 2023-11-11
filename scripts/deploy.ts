import * as fs from "fs";
import path from "path";
import hre, { ethers } from "hardhat";

import signedTx from "./presigned-createx-deployment-transaction/signed_serialised_transaction.json";

// Colour codes for terminal prints
const RESET = "\x1b[0m";
const GREEN = "\x1b[32m";
const RED = "\x1b[31m";

const dir = path.join(__dirname, "broadcasted-createx-deployment-transaction");

function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// eslint-disable-next-line @typescript-eslint/no-unused-vars
async function deployNormal() {
  const contract = await ethers.deployContract("CreateX");

  await contract.waitForDeployment();
  const contractAddress = await contract.getAddress();

  console.log("CreateX deployed to:", contractAddress);

  await delay(30000); // Wait for 30 seconds before verifying the contract

  await hre.run("verify:verify", {
    address: contractAddress,
  });
}

async function deployRaw() {
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
    const contractAddress = transactionReceipt?.contractAddress;
    console.log("Contract address: " + `${GREEN}${contractAddress}${RESET}`);

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

    await delay(30000); // Wait for 30 seconds before verifying the contract

    await hre.run("verify:verify", {
      address: contractAddress,
    });
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

deployRaw().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
