const { expect } = require("chai");
const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const {ethers} = require("hardhat");

describe("Payments", function() {

  let addr1, addr2, payments;
  beforeEach(async function() {
    [addr1, addr2] = await ethers.getSigners();
    const Payments = await ethers.getContractFactory("Payments");
    payments = await Payments.deploy();
    await payments.waitForDeployment();
  })

  it("should be deployed with address", async () => {
    const address  = await payments.getAddress();
    console.log("Payments deployed address", address);
    expect(address).to.be.properAddress;
  });

  it("should have 0 eth", async () => {
    const balance  = await payments.currentBalance();
    console.log("Balance", balance);
    expect(balance).to.equal(0);
  });

  it("should be possible to send funds", async () => {
    const sum = 42;
    const msg = "Hello";
    const tx  = await payments.pay(msg, { value: sum });

    await expect(() => tx).to.changeEtherBalances([addr1, payments], [-sum, sum]);


    const newPayment = await payments.getPayment(addr1, 0);
    console.log("New Payment", newPayment);

    expect(newPayment.message).to.equal(msg);
    expect(newPayment.amount).to.equal(sum);
    expect(newPayment.from).to.equal(addr1);
  });

})