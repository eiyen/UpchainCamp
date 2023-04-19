require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require("dotenv").config();

const { ProxyAgent, setGlobalDispatcher } = require("undici");
const proxyAgent = new ProxyAgent("http://127.0.0.1:7890");
setGlobalDispatcher(proxyAgent);

const { INFURA_SEPOLIA_RPC_URL, SEPOLIA_PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

module.exports = {
  solidity: "0.8.9",
  networks: {
    localhost: {
      url: "http://localhost:8545",
    },
    sepolia: {
      url:INFURA_SEPOLIA_RPC_URL,
      accounts: [SEPOLIA_PRIVATE_KEY],
    }
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  }
};