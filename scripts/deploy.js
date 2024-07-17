const hre = require('hardhat')
const ethers = hre.ethers

async function main() {
    const [signer] = await ethers.getSigners()

    const BRShop = await ethers.getContractFactory('BRShop', signer)
    const erc = await BRShop.deploy()
    await erc.waitForDeployment()
    console.log(erc.target)
    console.log(await erc.token())
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });