async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    // Deploy MyToken contract
    const MyToken = await ethers.getContractFactory("MyToken");
    const myToken = await MyToken.deploy();
    await myToken.deployed();
    console.log("MyToken contract address:", myToken.address);
  
    // Deploy TokenVault contract
    const TokenVault = await ethers.getContractFactory("TokenVault");
    const tokenVault = await TokenVault.deploy(myToken.address);
    await tokenVault.deployed();
    console.log("TokenVault contract address:", tokenVault.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  