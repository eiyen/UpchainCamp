require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

const { ProxyAgent, setGlobalDispatcher } = require("undici");
const proxyAgent = new ProxyAgent("http://127.0.0.1:7890");
setGlobalDispatcher(proxyAgent);

const { INFURA_RPC_URL, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

module.exports = {
  solidity: "0.8.4",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    goerli: {
      url: INFURA_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 5,
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};
