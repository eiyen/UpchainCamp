require("@nomiclabs/hardhat-ethers")

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with account: ", deployer.address);

    const Score = await ethers.getContractFactory("Score");
    const score = await Score.deploy();
    await score.deployed();
    console.log("Score constract deployed at: ", score.address);

    const Teacher = await ethers.getContractFactory("Teacher");
    const teacher = await Teacher.deploy(score.address);
    await teacher.deployed();
    console.log("Teacher contract deployed at: ", teacher.address);

    console.log("\nTransfering Score ownership to Teacher...");
    await score.transferOwnership(teacher.address);
    console.log("Owner of Score changed to: ", await score.owner());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })