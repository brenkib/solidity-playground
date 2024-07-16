const { expect } = require("chai");
const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const {ethers} = require("hardhat");

describe("Demo7", function() {

  let owner, addr1, demo7;
  beforeEach(async function() {
    [owner, addr1] = await ethers.getSigners();

    demo7 = await ethers.deployContract("Demo7", owner);

    await demo7.waitForDeployment();
  })

  async function sendMoney(sender) {
    const amount = 100;
    const txData = {
      to: demo7.target,
      value: amount,
    };

    const tx = await sender.sendTransaction(txData);
    await tx.wait();
    return [tx, amount];
  }

  it("should allow to send money", async () => {
    const [sendTx, amount] = await sendMoney(addr1)

    console.log("TX:", sendTx);

    expect(sendTx).to.changeEtherBalance(demo7, amount);

    const blockTimestamp = (await ethers.provider.getBlock(sendTx.blockNumber)).timestamp;
    expect(sendTx).to.emit(demo7, "Paid").withArgs(addr1, amount, blockTimestamp);
  });

  it("should allow owner to withdraw", async () => {
    const [_, amount] = await sendMoney(addr1)

    const tx = await demo7.withdraw(owner);

    await expect(() => tx).to.changeEtherBalances([demo7, owner], [-amount, amount]);
  });

  it("should NOT allow others to withdraw", async () => {
    const [_, amount] = await sendMoney(addr1)

    await expect(demo7.connect(addr1).withdraw(addr1)).to.be.revertedWith("Not owner")
  });

})