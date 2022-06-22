import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());
  // npx hardhat run scripts/Semaphore.ts --network localhost

  const PoseidonT3 = await ethers.getContractFactory("PoseidonT3");
  const poseidonT3 = await PoseidonT3.deploy();
  const PoseidonT6 = await ethers.getContractFactory("PoseidonT6");
  const poseidonT6 = await PoseidonT6.deploy();
  console.log("PoseidonT3 address:", poseidonT3.address);
  console.log("PoseidonT6 address:", poseidonT6.address);
  //console.log("Semaphore address:", semaphore.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
