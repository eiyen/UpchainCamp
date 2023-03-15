async function main() {
  const [signer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", signer.address);

  const Counter = await ethers.getContractFactory("Counter");
  const counter = await Counter.deploy();

  console.log("Counter contract deployed to:", counter.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })