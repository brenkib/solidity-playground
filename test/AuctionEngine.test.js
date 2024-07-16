const {expect} = require("chai");
const {ethers} = require("hardhat");

describe("AuctionEngine", function () {

    let owner, buyer, seller, auction;
    beforeEach(async function () {
        [owner, seller, buyer] = await ethers.getSigners();
        const AuctionEngine = await ethers.getContractFactory("AuctionEngine", owner);
        auction = await AuctionEngine.deploy();
        await auction.waitForDeployment();
    })

    it("should be correct owner", async () => {
        const _owner = await auction.owner();
        expect(_owner).to.equal(owner);
    });

    it("should create auction", async () => {
        const ITEM = "Car";
        const DURATION = 64000;
        const tx = await auction.createAuction(
            ethers.parseEther("0.001"),
            3,
            ITEM,
            DURATION
        );

        const createdAuction = await auction.auctions(0);

        console.log(createdAuction);

        expect(createdAuction.item).to.equal(ITEM);

        const blockTimestamp = (await ethers.provider.getBlock(tx.blockNumber)).timestamp;
        expect(createdAuction.endAt).to.equal(blockTimestamp + DURATION);
    });


    function delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    it("should buy item", async () => {
        const ITEM = "FAKE CAR 2";
        const DURATION = 60;
        const tx = await auction.connect(seller).createAuction(
            ethers.parseEther("0.001"),
            5,
            ITEM,
            DURATION
        );
        this.timeout(5000);
        await delay(1000);
        const txBuy = await auction.connect(buyer).buy(0, {value: ethers.parseEther("0.002")});

        const createdAuction = await auction.auctions(0);
        console.log(createdAuction);
        const finalPrice =
            BigInt(createdAuction.finalPrice - (createdAuction.finalPrice * BigInt(10) / BigInt(100)));
        expect(txBuy).to.changeEtherBalance(seller, finalPrice)

        expect(txBuy).to.emit(auction, "AuctionEnded").withArgs(0, finalPrice, buyer)

    });


})