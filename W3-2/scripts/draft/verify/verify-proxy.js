const hre = require("hardhat");

async function main() {
    const PROXY_ADDRESS = "0xA9EFa830596ED7a70804D53af9427165bb192d05";
    const constructorArguments = [];

    console.log("Verifying contract on Etherscan...");
    await hre.run("verify:verify", {
        address: PROXY_ADDRESS,
        constructorArguments: constructorArguments,
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });