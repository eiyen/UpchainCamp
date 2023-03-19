const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // Deploy Score contract
  const Score = await hre.ethers.getContractFactory("Score");
  const score = await Score.deploy({ gasLimit: 7000000 });
  await score.deployed();
  console.log("Score contract deployed at:", score.address);

  // Deploy Teacher contract using deployTeacherUsingCreate2
  const teacherAddress = await score.deployTeacherUsingCreate2();
  console.log("Teacher contract deployed at:", teacherAddress.to);

  // Get the Teacher contract address
  console.log("Owner of Score contract:", await score.owner());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
