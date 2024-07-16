const { expect } = require("chai");
const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const {ethers} = require("hardhat");

describe("MerkleTree", function() {

  let addr1, addr2, merkleTree;
  beforeEach(async function() {
    [addr1] = await ethers.getSigners();
    const MerkleTree = await ethers.getContractFactory("MerkleTree");
    merkleTree = await MerkleTree.deploy();
    await merkleTree.waitForDeployment();
  })

  it("should verify hash against tree", async () => {
    const transactionToTest = await merkleTree.transactions(2);
    const rootHash = await merkleTree.hashes(6);

    const dependencyHash1 = await merkleTree.hashes(3);
    const dependencyHash2 = await merkleTree.hashes(4);

    const verifyResult = await merkleTree.verify(
      transactionToTest, // tx
       2, //tx index
      rootHash, //root hash
      [dependencyHash1, dependencyHash2]
    )

    expect(verifyResult).to.be.true;
  });


  it("should NOT verify hash of tx against tree", async () => {
    const transactionToTest = "TX125125: NEW -> TEST";
    const rootHash = await merkleTree.hashes(6);

    const dependencyHash1 = await merkleTree.hashes(3);
    const dependencyHash2 = await merkleTree.hashes(4);

    const verifyResult = await merkleTree.verify(
      transactionToTest, // tx
      2, //tx index
      rootHash, //root hash
      [dependencyHash1, dependencyHash2]
    )

    expect(verifyResult).to.be.false;
  });

})