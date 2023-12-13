import * as fs from "fs";
import path from "path";
import hre from "hardhat";

import initCode from "./contract_creation_bytecode_createx.json";
import signedTx from "./presigned-createx-deployment-transactions/signed_serialised_transaction_gaslimit_3000000_.json";
import abi from "../abis/src/CreateX.sol/CreateX.json";

// Colour codes for terminal prints
const RESET = "\x1b[0m";
const GREEN = "\x1b[32m";
const RED = "\x1b[31m";

// The `keccak256` hashes of the pre-signed transactions:
// - 0xb6274b80bc7cda162df89894c7748a5cb7ba2eaa6004183c41a1837c3b072f1e (3m gasLimit)
// - 0xc8354e4112f3c78ecfb985f7d1935cb4a8a625cb0b000a4cf0aff327c0708d4c (25m gasLimit)
// - 0x891a2cf734349124752970c4b5666b5b71e9db38c40cb8aab493a11e5c85d6fd (45m gasLimit)
const signedTxHashes = [
  "0xb6274b80bc7cda162df89894c7748a5cb7ba2eaa6004183c41a1837c3b072f1e",
  "0xc8354e4112f3c78ecfb985f7d1935cb4a8a625cb0b000a4cf0aff327c0708d4c",
  "0x891a2cf734349124752970c4b5666b5b71e9db38c40cb8aab493a11e5c85d6fd",
];

const dir = path.join(__dirname, "broadcasted-createx-deployment-transactions");

function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// eslint-disable-next-line @typescript-eslint/no-unused-vars
async function deployNormal() {
  // Ensure the correct contract creation bytecode is used
  if (
    hre.ethers.keccak256(initCode) !=
    "0x12ec861579b63a3ab9db3b5a23c57d56402ad3061475b088f17054e2f2daf22f"
  ) {
    throw new Error("Incorrect contract creation bytecode.");
  }

  const createxFactory = await hre.ethers.getContractFactory(abi, initCode);
  const createx = await createxFactory.deploy();

  await createx.waitForDeployment();
  const createxAddress = await createx.getAddress();

  console.log("CreateX deployed to:", createxAddress);

  await delay(30000); // Wait for 30 seconds before verifying `CreateX`

  await hre.run("verify:verify", {
    address: createxAddress,
  });
}

async function deployRaw() {
  // Ensure a correct pre-signed transaction is used
  if (!signedTxHashes.includes(hre.ethers.keccak256(signedTx))) {
    throw new Error("Incorrect pre-signed transaction.");
  }

  try {
    // Send the transaction
    const tx = await hre.ethers.provider.broadcastTransaction(signedTx);
    console.log("Transaction hash: " + `${GREEN}${tx.hash}${RESET}`);
    const transactionReceipt = await tx.wait();
    const createxAddress = transactionReceipt?.contractAddress;
    console.log("Contract address: " + `${GREEN}${createxAddress}${RESET}`);

    // Save the transaction receipt in a JSON file
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir);
    }
    const saveDir = path.normalize(
      path.join(dir, `transaction_receipt_date_${Date.now().toString()}.json`),
    );
    fs.writeFileSync(saveDir, JSON.stringify(transactionReceipt));

    console.log(
      `\n${GREEN}Transaction has been successfully broadcasted!${RESET}`,
    );
    console.log(`Transaction details written to: ${GREEN}${saveDir}${RESET}\n`);

    await delay(30000); // Wait for 30 seconds before verifying `CreateX`

    await hre.run("verify:verify", {
      address: createxAddress,
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
