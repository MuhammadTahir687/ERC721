const MyRinkebyToken = artifacts.require('./TestNFT.sol')

module.exports = function (deployer) {
  
  deployer.then(async () => {
    await deployer.deploy(MyRinkebyToken)
    const myTokenInstance = await MyRinkebyToken.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log(`Contract Address: ${myTokenInstance.address}`)
    console.log('\n*************************************************************************\n')
  })
}
// 0x88951e18fEd6D792d619B4A472d5C0D2E5B9b5F0
// 0x1536EF5C6172C8a34c640F527e0cF674aA4DC82D
