const { ethers, upgrades } = require("hardhat");

async function main() {
    const PROXY_ADDRESS = "0xA9EFa830596ED7a70804D53af9427165bb192d05";
    
    const MyERC20V2 = await ethers.getContractFactory("MyERC20V2");
    console.log("Upgrading MyERC20V2...");
    await upgrades.upgradeProxy(PROXY_ADDRESS, MyERC20V2);
    console.log("Upgraded!");

    // Proxy contract address
    console.log("MyERC20V2 proxy address: ", PROXY_ADDRESS);

    // Implementation contract address
    const admin = await upgrades.admin.getInstance();
    const implAddress = await admin.getProxyImplementation(PROXY_ADDRESS);
    console.log("MyERC20V2 implementation deployed to: ", implAddress);

    // Verify contract
    console.log("Verifying contract on Etherscan...");
    await hre.run("verify:verify", {
        address: proxyAddress,
        constructorArguments: [],
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });