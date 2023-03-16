require("@nomiclabs/hardhat-waffle");
require('dotenv').config();

const { INFURA_RPC_URL, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

module.exports = {
  solidity: "0.8.4",
  networks: {
    goerli: {
      url: INFURA_RPC_URL,
      accounts: [PRIVATE_KEY]
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  },
};
