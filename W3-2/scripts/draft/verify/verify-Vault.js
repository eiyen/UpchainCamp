const hre = require("hardhat");

async function main() {
    const Vault_CONTRACT_ADDRESS = "0x5743Be6A9F92c79071456d7DdFC48Aa7Fe267AC4";
    const PROXY_ADDRESS = "0xA9EFa830596ED7a70804D53af9427165bb192d05";
    const constructorArguments = [PROXY_ADDRESS];

    console.log("Verifying contract on Etherscan...");
    await hre.run("verify:verify", {
        address: Vault_CONTRACT_ADDRESS,
        constructorArguments: constructorArguments,
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });