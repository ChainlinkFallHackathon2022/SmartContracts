require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

// const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
// const GOERLI_PRIVATE_KEY = process.env.GOERLI_PRIVATE_KEY;
// const GOERLI_SCAN_KEY = process.env.GOERLI_SCAN_KEY;
const ALCHEMY_API_KEY_MUMBAI = process.env.ALCHEMY_API_KEY_MUMBAI;
const MUMBAI_PRIVATE_KEY = process.env.MUMBAI_PRIVATE_KEY;
const MUMBAI_SCAN_KEY = process.env.MUMBAI_SCAN_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    hardhat: {},
    // goerli: {
    //   url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
    //   accounts: [GOERLI_PRIVATE_KEY],
    // },
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API_KEY_MUMBAI}`,
      accounts: [MUMBAI_PRIVATE_KEY],
      gas:300000,
    },
  },
  etherscan: {
    apiKey: MUMBAI_SCAN_KEY, // Your Etherscan API key
  },
};
