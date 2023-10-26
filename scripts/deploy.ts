import hre, { ethers } from "hardhat";

async function main() {
  const contract = await ethers.deployContract("CreateX");

  await contract.waitForDeployment();

  console.log("CreateX deployed to:", await contract.getAddress());

  await hre.run("verify:verify", {
    address: contract.getAddress(),
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
