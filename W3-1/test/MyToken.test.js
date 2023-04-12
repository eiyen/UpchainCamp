const { expect } = require("chai");

describe("MyToken and TokenVault", function () {
  let MyToken, myToken, TokenVault, tokenVault, owner, addr1, addr2;

  beforeEach(async function () {
    MyToken = await ethers.getContractFactory("MyToken");
    myToken = await MyToken.deploy();
    await myToken.deployed();

    TokenVault = await ethers.getContractFactory("TokenVault");
    tokenVault = await TokenVault.deploy(myToken.address);
    await tokenVault.deployed();

    [owner, addr1, addr2] = await ethers.getSigners();
  });

  describe("Deployment", function () {
    it("should set the right token contract address", async function () {
      const tokenAddress = await tokenVault.token();
      expect(tokenAddress).to.equal(myToken.address);
    });

    it("should mint 1000 MyToken", async function () {
      await myToken.connect(owner).mint(owner.address, 1000);
      const ownerBalance = await myToken.balanceOf(owner.address);
      expect(ownerBalance).to.equal(1000);
    });

    it("should deposit 1000 MyToken to TokenVault", async function () {
      await myToken.connect(owner).mint(owner.address, 1000);
      await myToken.connect(owner).approve(tokenVault.address, 1000);
      await tokenVault.connect(owner).deposit(1000);

      const vaultBalance = await tokenVault.balanceOf(owner.address);
      expect(vaultBalance).to.equal(1000);
    });
  });
});
