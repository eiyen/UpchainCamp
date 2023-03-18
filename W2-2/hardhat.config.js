require("@nomiclabs/hardhat-waffle");
require("dotenv").config();

const { INFURA_RPC_URL, PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.8.4",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    goerli: {
      url: INFURA_RPC_URL,
      accounts: [PRIVATE_KEY],
    }
  }
};
