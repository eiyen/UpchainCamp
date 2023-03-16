require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config();

const { ProxyAgent, setGlobalDispatcher } = require("undici");

const proxyAgent = new ProxyAgent("http://127.0.0.1:10809")
setGlobalDispatcher(proxyAgent)

const { INFURA_API_KEY, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

module.exports = {
  solidity: "0.8.4",
  networks: {
    goerli: {
      url: `https://goerli.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY],
      chainId: 5
    }
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  }
};
