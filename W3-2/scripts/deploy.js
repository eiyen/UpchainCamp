/**
 * 目标：在一个 JS 文件中，实现多个合约的部署、升级和验证的过程。
 * 
 * [BUG]
 * ====
 * [错误]
 * 这里在进行到 verifyContract() 函数的 hre.run 时，会出现以下报错:
 * 
 * Deploying MyERC20V1...
 * MyERC20V1 deployed!
 * Verifying Contract on Etherscan...
 * TypeError: Cannot read properties of undefined (reading 'run')
 * 
 * 意味着在 hre 中无法找到 run 这一插件，但是很明显 run 可以被直接运行，
 * 例如 npx hardhat run.
 * 
 * [解决方案]
 * 无需在 require 中显性地导入 hre.
 * ====
 */

const { ethers, upgrades } = require("hardhat");

async function deployMyERC20V1() {
    const MyERC20V1 = await ethers.getContractFactory("MyERC20V1");
    console.log("Deploying MyERC20V1...");
    const myERC20V1 = await upgrades.deployProxy(MyERC20V1);
    await myERC20V1.deployed();
    console.log("MyERC20V1 deployed!");
    return myERC20V1;
}

function wait(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}
  

async function verifyContract(contract, contractName, constructorArguments = []) {
    console.log("Waiting for 30 seconds before verifying...");
    await wait(30000);
    
    console.log(`Verifying ${contractName} on Etherscan...`);
    await hre.run("verify:verify", {
        address: contract.address,
        constructorArguments: constructorArguments,
    });

    console.log(`${contractName} verified on Etherscan`);
}

async function upgradeToMyERC20V2(proxyAddress) {
    const MyERC20V2 = await ethers.getContractFactory("MyERC20V2");
    console.log("Upgrading to MyERC20V2...");
    await upgrades.upgradeProxy(proxyAddress, MyERC20V2);
    console.log("Upgraded to MyERC20V2!");
    return await ethers.getContractAt("MyERC20V2", proxyAddress);
}

async function deployVault(proxyAddress) {
    const Vault = await ethers.getContractFactory("Vault");
    console.log("Deploying Vault...");
    const vault = await Vault.deploy(proxyAddress);
    await vault.deployed();
    console.log("Vault deployed!");
    return vault;
}

async function main() {
    // Deploy MyERC20V1
    const myERC20V1 = await deployMyERC20V1();
    const admin = await upgrades.admin.getInstance();
    const implAddress = await admin.getProxyImplementation(myERC20V1.address);
    await verifyContract(myERC20V1, "myERC20V1");

    // Upgrade to MyERC20V2
    const myERC20V2 = await upgradeToMyERC20V2(myERC20V1.address);
    const newImplAddress = await admin.getProxyImplementation(myERC20V1.address);
    await verifyContract(myERC20V2, "myERC20V2");

    // Deploy Vault contract
    const vault = await deployVault(myERC20V2.address);
    await verifyContract(vault, "vault", [myERC20V2.address]);

    console.log("MyERC20V1 proxy deployed to: ", myERC20V1.address);
    console.log("MyERC20V1 implementation deployed to: ", implAddress);
    console.log("MyERC20V2 implementation deployed to: ", newImplAddress);
    console.log("Vault deployed to: ", vault.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
