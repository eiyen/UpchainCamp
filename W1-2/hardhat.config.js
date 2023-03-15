require("@nomiclabs/hardhat-waffle");

const { API_KEY, PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.8.4",
  networks: {
    goerli: {
      url: `https://goerli.infura.io/v3/${API_KEY}`,
      accounts: [PRIVATE_KEY],
      chainId: 5
    }
  }
};
