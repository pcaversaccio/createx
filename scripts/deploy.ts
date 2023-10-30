import hre, { ethers } from "hardhat";

function delay(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const contract = await ethers.deployContract("CreateX");

  await contract.waitForDeployment();
  const contractAddress = await contract.getAddress();

  console.log("CreateX deployed to:", contractAddress);

  await delay(30000); // Wait for 30 seconds before verifying the contract

  await hre.run("verify:verify", {
    address: contractAddress,
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
