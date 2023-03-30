require("@nomiclabs/hardhat-ethers");

async function deploy() {
    
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with account: ", deployer.address);

    const CorrorToken = await ethers.getContractFactory("CorrorToken");
    const initialSupply = 100000;
    const corrorToken = await CorrorToken.deploy(initialSupply);
    await corrorToken.deployed()
    console.log("CorrorToken deployed at: ", corrorToken.address);

    const CorrorVault = await ethers.getContractFactory("CorrorVault");
    const corrorVault = await CorrorVault.deploy(corrorToken.address);
    await corrorVault.deployed();
    console.log("CorrorVault deployed at: ", corrorVault.address);
}

deploy()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })