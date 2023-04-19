const { ethers, upgrades, hre } = require("hardhat");

async function main() {
    const MyERC20V1 = await ethers.getContractFactory("MyERC20V1");

    // Deploy contract
    console.log("Deploying MyERC20V1...");
    const myERC20V1 = await upgrades.deployProxy(MyERC20V1);
    await myERC20V1.deployed();
    console.log("MyERC20V1 deployed!");

    // Proxy contract address
    const proxyAddress = myERC20V1.address;
    console.log("MyERC20V1 proxy deployed to: ", proxyAddress);

    // Implementation contract address
    const admin = await upgrades.admin.getInstance();
    const implAddress = await admin.getProxyImplementation(proxyAddress);
    console.log("MyERC20V1 implementation deployed to: ", implAddress);

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