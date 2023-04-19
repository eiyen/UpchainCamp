const { ethers } = require("hardhat");

async function main() {
    // const MyERC20V2_CONTRACT_ADDRESS = "0x69F275bCC40D6C1ff46d335FF4C09D2239d5419f";
    const PROXY_ADDRESS = "0xA9EFa830596ED7a70804D53af9427165bb192d05";

    const Vault = await ethers.getContractFactory("Vault");
    console.log("Deploying Vault...");
    const vault = await Vault.deploy(PROXY_ADDRESS);
    await vault.deployed();
    console.log("Vault deployed to: ", vault.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });