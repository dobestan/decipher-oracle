const hre = require("hardhat");


async function main() {
  const [deployer] = await ethers.getSigners();

  const BtcPriceOracle = await hre.ethers.getContractFactory("BtcPriceOracle");
  const btcPriceOracle = await BtcPriceOracle.deploy();
  await btcPriceOracle.deployed();

  const Caller = await hre.ethers.getContractFactory("Caller");
  const caller = await Caller.deploy(btcPriceOracle.address);
  await caller.deployed();

  console.log("Deployer is: " + deployer.address);
  console.log("BtcPriceOracle contract deployed at: " + btcPriceOracle.address);
  console.log("Caller contract deployed at: " + caller.address);
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
