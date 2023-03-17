const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account: ", deployer.address);

    const TestBank = await ethers.getContractFactory("TestBank");
    const testBank = await TestBank.deploy();

    console.log("Bank contract deployed to: ", testBank.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })