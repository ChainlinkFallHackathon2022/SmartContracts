const hre = require("hardhat");


async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  console.log("\n\n");



  const currency = "0xD6920eeAF9b9bc7288765F72B4d6Da3e47308464";
  const _link = "0x326C977E6efc84E512bB9C30f76E30c160eD06FB";
  const _registrar = "0xDb8e8e2ccb5C033938736aa89Fe4fa1eDfD15a1d";
  const _registry = "0x02777053d6764996e594c3E88AF1D58D5363a2e6";

  const NFTGridDataAddress = "0xE8B0c5d509050D26481FA75767558E6740f84C43"
  const upKeepIDRegisterFactoryAddress = "0x358395de7e042a9707DAb7050DF137D422f1ADBc"

  // const NFTGridData = await hre.ethers.getContractFactory("NFTGridData");
  // const nftGridData = await NFTGridData.deploy();
  // await nftGridData.deployed();
  
  // const UpKeepIDRegisterFactory = await hre.ethers.getContractFactory("UpKeepIDRegisterFactory");
  // const upKeepIDRegisterFactory = await UpKeepIDRegisterFactory.deploy(_link,_registrar,_registry);
  // await upKeepIDRegisterFactory.deployed();


  const GridBotFactory = await hre.ethers.getContractFactory("GridBotFactory");
  const gridBotFactory = await GridBotFactory.deploy(NFTGridDataAddress,currency,upKeepIDRegisterFactoryAddress );
  await gridBotFactory.deployed();

  // console.log(`  nftGridData Address: ${nftGridData.address}`);
  // console.log(`  upKeepIDRegisterFactory Address: ${upKeepIDRegisterFactory.address}`);
  console.log(`  GridBotFactory Address: ${gridBotFactory.address}`);

  const WAIT_BLOCK_CONFIRMATION = 6;
  // await nftGridData.deployTransaction.wait(WAIT_BLOCK_CONFIRMATION);
  await gridBotFactory.deployTransaction.wait(WAIT_BLOCK_CONFIRMATION);
  // await upKeepIDRegisterFactory.deployTransaction.wait(WAIT_BLOCK_CONFIRMATION);

  console.log(`Verifying contract on Scan`);

  
  
  await run(`verify:verify`,{
    address: gridBotFactory.address,
    constructorArguments: [
      NFTGridDataAddress,
      currency,
      upKeepIDRegisterFactoryAddress
    ],
    contract: "contracts/GridBotFactory.sol:GridBotFactory",
  })
  
//   await run(`verify:verify`,{
//     address: nftGridData.address,
//     constructorArguments: [    
//     ],
//     contract: "contracts/NFTGridData.sol:NFTGridData",
//   })
  
//   await run(`verify:verify`,{
//     address: upKeepIDRegisterFactory.address,
//     constructorArguments: [    
//       _link,
//       _registrar,
//       _registry
//     ],
//     contract: "contracts/UpKeepIDRegisterFactory.sol:UpKeepIDRegisterFactory",
//   })
  console.log(`\n\n END Script`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
