const { assertion } = require("@openzeppelin/test-helpers/src/expectRevert");

const BlindBoxFactory = artifacts.require("BlindBoxFactory");
const GameItemFactory = artifacts.require("GameItemFactory");
const BlindBox = artifacts.require("BlindBox");
const CyberpopGame = artifacts.require('CyberpopGame')

contract("BlindBoxFactory", function ([owner, userA]) {
  let bb, gameItemFactory, game
  beforeEach(async () => {
    bb = await BlindBoxFactory.deployed()
    gameItemFactory = await GameItemFactory.deployed()
    game = await CyberpopGame.deployed()
  })

  it("adds new option", async function () {
    // let probabilities = [
    //   [0.125, 0.125, 0.125, 0.125, 0.05, 0.05, 0.05, 0.05, 0.005, 0.005, 0.005, 0.005],
    //   [0.15, 0.15, 0.15, 0.15, 0.0625, 0.0625, 0.0625, 0.0625, 0.015, 0.015, 0.015, 0.015],
    //   [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.075, 0.075, 0.075, 0.075]
    // ]
    // for (let i = 0; i < probabilities.length; i++) {
    //   await bb.addNewOption(gameItemFactory.address, probabilities[i].map(x => x * 10000))
    // }
    await bb.grantMinter(owner)
    let addresses = await bb.boxAddresses()
    assert.equal(addresses.length, 3)
    let box = await BlindBox.at(addresses[0])
    await box.safeMint(userA)
    let balance = await box.balanceOf(userA)
    assert.equal(balance.toString(), '1')
    let tokenId = await box.tokenOfOwnerByIndex(userA, 0)
    await bb.unpack(addresses[0], tokenId, { from: userA })
  })
})
