const {expect} = require("chai")
const {ethers} = require("hardhat")
const tokenJSON = require("../artifacts/contracts/ERC.sol/BRToken.json")

describe("BRShop", function () {
    let owner
    let buyer
    let shop
    let erc20

    beforeEach(async function () {
        [owner, buyer] = await ethers.getSigners()

        const BRShop = await ethers.getContractFactory("BRShop", owner)
        shop = await BRShop.deploy()
        await shop.waitForDeployment();

        erc20 = new ethers.Contract(await shop.token(), tokenJSON.abi, owner)
    })

    it("should have an owner and a token", async function () {
        expect(await shop.owner()).to.eq(owner.address)

        expect(await shop.token()).to.be.properAddress;
    })

    it("allows to buy", async function () {
        const tokenAmount = 3

        const txData = {
            value: tokenAmount,
            to: shop.target
        }

        const tx = await buyer.sendTransaction(txData)
        await tx.wait()

        expect(await erc20.balanceOf(buyer.address)).to.eq(tokenAmount)

        await expect(() => tx).to.changeEtherBalance(shop, tokenAmount)

        await expect(tx)
            .to.emit(shop, "Bought")
            .withArgs(tokenAmount, buyer.address)
    })

    it("allows to sell", async function () {
        await buyer.sendTransaction({value: 3, to: shop})
        const sellAmount = 2

        await erc20.connect(buyer).approve(shop, sellAmount);
        const sellTx = await shop.connect(buyer).sell(sellAmount)

        await expect(sellTx)
            .to.emit(shop, "Sold")
            .withArgs(sellAmount, buyer);

        await expect(() => sellTx).to.changeEtherBalance(shop, -sellAmount);

        await expect(sellTx)
            .to.emit(erc20, "Transfer")
            .withArgs(buyer, shop, sellAmount);

        console.log(await erc20.balances(buyer));
        expect(await erc20.balanceOf(buyer)).to.eq(1);
    })
})