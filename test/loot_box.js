const LootBox = artifacts.require("LootBox");
const CyberClub = artifacts.require("CyberClub");
const CyberpopGame = artifacts.require("CyberpopGame");
const Cyborg = artifacts.require("Cyborg");

const CyberClubFactory = artifacts.require("CyberClubFactory")

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("LootBox", function (accounts) {
  let lootbox, cyberClub, badge, cyborg, owner, userA

  before(async () => {
    lootbox = await LootBox.deployed()
    cyberClub = await CyberClub.deployed()
    badge = await CyberpopGame.deployed()
    cyborg = await Cyborg.deployed()
    owner = accounts[0]
    userA = accounts[1]
    await lootbox.mintBatch(userA, [0, 1, 2], [1, 2, 1], '0x')
  })

  it("opens Avatar Box", async function () {
    await lootbox.unpack(0, 1, { from: userA })
  })

  it("opens comsumerable Box", async function () {
    await lootbox.unpack(1, 1, { from: userA })
  })

  it("opens Charater Box", async function () {
    await lootbox.unpack(2, 1, { from: userA })
  })

  it("can add new option", async () => {
    let factory = await CyberClubFactory.deployed()
    await lootbox.addNewOption(factory.address, [10000])
  })

  it("can modify probabitlies", async () => {
    await lootbox.setProbabilitiesForOption(1, [0, 9500, 500])
    await lootbox.unpack(1, 1, { from: userA })
  })
})
