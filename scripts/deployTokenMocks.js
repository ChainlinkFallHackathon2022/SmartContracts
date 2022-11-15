const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  console.log("\n\n");

  const BTCMock = await hre.ethers.getContractFactory("BTCMock");
  const btcMock = await BTCMock.deploy();
  await btcMock.deployed();

  const USDCMock = await hre.ethers.getContractFactory("USDCMock");
  const usdcMock = await USDCMock.deploy();
  await usdcMock.deployed();

  const WETHMock = await hre.ethers.getContractFactory("WETHMock");
  const wethMock = await WETHMock.deploy();
  await wethMock.deployed();

  console.log(` 
    BTCMock Address: ${btcMock.address} \n 
    USDCMock Address: ${usdcMock.address} \n 
    WETHMock Address: ${wethMock.address} 
  `);



  const WAIT_BLOCK_CONFIRMATION = 6;
  await btcMock.deployTransaction.wait(WAIT_BLOCK_CONFIRMATION);

  console.log(`Verifying contract on Scan`);

  await run(`verify:verify`,{
    address: btcMock.address,
    constructorArguments: [],
    contract: "contracts/tokenMocks/BTCMock.sol:BTCMock",
  })

  await run(`verify:verify`,{
    address: usdcMock.address,
    constructorArguments: [],
    contract: "contracts/tokenMocks/USDCMock.sol:USDCMock",
  })

  await run(`verify:verify`,{
    address: wethMock.address,
    constructorArguments: [],
    contract: "contracts/tokenMocks/WETHMock.sol:WETHMock",
  })

  console.log(`\n\n END Script`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
