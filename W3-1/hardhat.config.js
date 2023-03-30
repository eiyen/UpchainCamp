require("@nomiclabs/hardhat-waffle");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");

const { ProxyAgent, setGlobalDispatcher } = require("undici");
const proxyAgent = new ProxyAgent("http://127.0.0.1:7890");
setGlobalDispatcher(proxyAgent);

const { INFURA_RPC_URL, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

module.exports = {
  solidity: "0.8.9",
  networks: {
    localhost: {
      url: "http://localhost:8545",
    },
    goerli: {
      url:INFURA_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 5,
    }
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  }
};