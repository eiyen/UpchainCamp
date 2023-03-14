const { ethers } = require("ethers");

// 获取合约实例并部署合约
async function main() {
  // 1. 连接 Hardhat 网络（默认是 localhost:8545）
  const provider = new ethers.providers.JsonRpcProvider();

  // 2. 获取默认 signer
  const signer = provider.getSigner();

  // 3. 加载合约的编译信息和 ABI
  const contractName = "Counter";
  const contractJson = require(`.\artifacts\contracts\Counter.sol\Counter.json`);
  const contractAbi = contractJson.abi;
  const contractBytecode = contractJson.bytecode;

  // 4. 实例化一个合约工厂
  const contractFactory = new ethers.ContractFactory(contractAbi, contractBytecode, signer);

  // 5. 部署合约
  console.log("部署合约到 Hardhat 网络...");
  const deployedContract = await contractFactory.deploy();
  console.log(`合约已部署到地址：${deployedContract.address}`);
}

// 确保有异常时，能够及时表明原因
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
