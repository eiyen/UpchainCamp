const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Counter", function () {
    let Counter;
    let counter;
    let owner;
    let addr1;

    beforeEach(async function () {
        [owner, addr1] = await ethers.getSigners();
        Counter = await ethers.getContractFactory("Counter");
        counter = await Counter.deploy();
        await counter.deployed();
    })

    it("Should count when called by the owner", async function () {
        const initialCounter = await counter.getCounter();
        expect(initialCounter).to.equal(0);

        const valueToAdd = 5;

        await (await counter.connect(owner).count(valueToAdd)).wait();

        const updatedCounter = await counter.getCounter();
        expect(updatedCounter).to.equal(initialCounter.add(valueToAdd));
    })

    it("Should fail when count() is called by someone other than the owner", async function () {
        const valueToAdd = 5;
        await expect(counter.connect(addr1).count(valueToAdd)).to.be.revertedWith("Only the contract owner can call this function.");
    });    
})