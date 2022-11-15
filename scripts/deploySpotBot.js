const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

    const stableCoin_= "0xD6920eeAF9b9bc7288765F72B4d6Da3e47308464";       // address
    const tradeableToken_= "0x8cdA7F95298418Bb6b5e424c1EEE4B18a0C1139C";    //address
    const dataFeed_= "0x007A22900a3B98143368Bd5906f8E17e9867581b";          //address
    const buyPrice_= "2028014769344";          //uint
    const sellPrice_= "2000000000000";         //uint
    const initialAmount_= "100000000000000000000";     //uint
    const ownerOfBot_= deployer.address;        //address
    const _swapRouter= "0xE592427A0AEce92De3Edee1F18E0157C05861564";        //address


  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  console.log("\n\n");

  const SpotBot = await hre.ethers.getContractFactory("SpotBot");
  const spotBot = await SpotBot.deploy(
    stableCoin_,
    tradeableToken_,
    dataFeed_,
    buyPrice_,
    sellPrice_,
    initialAmount_,
    ownerOfBot_,
    _swapRouter
    );
  await spotBot.deployed();

  console.log(`  spotBot Address: ${spotBot.address}`);


  const WAIT_BLOCK_CONFIRMATION = 6;
  await spotBot.deployTransaction.wait(WAIT_BLOCK_CONFIRMATION);

  console.log(`Verifying contract on Scan`);

  await run(`verify:verify`,{
    address: spotBot.address,
    constructorArguments: [
      stableCoin_,
      tradeableToken_,
      dataFeed_,
      buyPrice_,
      sellPrice_,
      initialAmount_,
      ownerOfBot_,
      _swapRouter
    ],
    contract: "contracts/SpotBot.sol:SpotBot",
  })



  
  console.log(`\n\n END Script`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
