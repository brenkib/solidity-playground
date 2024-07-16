const { expect } = require("chai");
const {ethers} = require("hardhat");

describe("AuctionEngine", function() {

    let owner, buyer, seller, auction;
    beforeEach(async function() {
        [owner, seller, buyer] = await ethers.getSigners();
        const AuctionEngine = await ethers.getContractFactory("AuctionEngine", owner);
        auction = await AuctionEngine.deploy();
        await auction.waitForDeployment();
    })

    it("should be correct owner", async () => {
        const _owner  = await auction.owner();
        expect(_owner).to.equal(owner);
    });

})