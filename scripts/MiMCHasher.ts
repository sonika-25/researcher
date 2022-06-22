import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());
  // npx hardhat run scripts/MiMCHasher.ts --network localhost

  const MiMCHasher = await ethers.getContractFactory("MiMCHasher");
  const miMCHasher = await MiMCHasher.deploy();

  console.log("MiMCHasher address:", miMCHasher.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
