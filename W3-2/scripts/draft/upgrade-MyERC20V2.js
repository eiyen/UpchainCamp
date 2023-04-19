const { ethers, upgrades } = require("hardhat");
// const { getImplementationAddress } = require('@openzeppelin/upgrades-core');

async function main() {
    const EXISTING_CONTRACT_ADDRESS = "0xBd072EEBD4940A7515d00377f3DD7950cbB55ac5";
    
    const MyERC20V2 = await ethers.getContractFactory("MyERC20V2");
    console.log("Deployiing MyERC20V2...");
    await upgrades.upgradeProxy(EXISTING_CONTRACT_ADDRESS, MyERC20V2);

    /// 这一步有Bug, 返回的是 V1 实现合约的地址。
    // let currentImplAddress = await getImplementationAddress(ethers.provider, myERC20V2ContractAddress.address);
    // console.log("MyERC20V2 has upgraded at: ", currentImplAddress);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });