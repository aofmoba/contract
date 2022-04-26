const { expectEvent } = require("@openzeppelin/test-helpers");

const LootBox = artifacts.require("LootBox");
const CyberClub = artifacts.require("CyberClub");
const CyberpopGame = artifacts.require("CyberpopGame");
const Cyborg = artifacts.require("Cyborg");

const CyberClubFactory = artifacts.require("CyberClubFactory")
const CharacterFactory = artifacts.require("CharacterFactory")
const FixLvlCharFactory = artifacts.require("FixLvlCharFactory")

contract("LootBox", function ([owner, userA, userB]) {
  let lootbox, cyberClub, badge, cyborg

  before(async () => {
    lootbox = await LootBox.deployed()
    cyberClub = await CyberClub.deployed()
    badge = await CyberpopGame.deployed()
    cyborg = await Cyborg.deployed()
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
    let arr = [0, 9500, 500]
    await lootbox.setProbabilitiesForOption(1, arr)
    let probabilities = await lootbox.classProbabilities(1)
    assert.deepEqual(arr, probabilities.map(p => p.toNumber()))

    await lootbox.unpack(1, 1, { from: userA })
  })

  it("can modify factory", async () => {
    let factory = await CyberClubFactory.deployed()
    await lootbox.setFactoryForOption(0, factory.address)
    let addr = await lootbox.classFactoryAddress(0)
    assert.equal(addr, factory.address)
  })

  it("supports totalSupply", async () => {
    let total = await lootbox.totalSupply(0)
    assert.equal(total.toNumber(), 1)
  })

  it("returns numOptions", async () => {
    let total = await lootbox.numOptions()
    assert.isTrue(total.toNumber() > 1)
  })

  context("CharacterFactory", async () => {
    let characterFactory
    before(async () => {
      characterFactory = await CharacterFactory.deployed()
    })

    it("mints random level character", async () => {
      let tokens = await cyborg.tokensOfOwner(userB)
      assert.deepEqual(tokens, [])
      await lootbox.mint(userB, 1, 9, '0x')
      await lootbox.setFactoryForOption(1, characterFactory.address)
      for(let i = 0; i < 9; i++) {
        let arr = [0,0,0,0,0,0,0,0, 0]
        arr[i] = 10000 // force mint level i + 1
        await lootbox.setProbabilitiesForOption(1, arr)
        let tx = await lootbox.unpack(1, 1, {from: userB})
        const blockNumber = tx.receipt.blockNumber
        const events = await cyborg.getPastEvents("Transfer", {fromBlock: blockNumber, toBlock: blockNumber})

        let tokenId = events[0].args.tokenId.toNumber()
        assert.isTrue(tokenId.toString().startsWith((i + 1).toString()))
      }
    })
  })

  context("FixLvlCharFactory", async () => {
    let fixLvlCharFactory, boxId

    before(async () => {
      fixLvlCharFactory = await FixLvlCharFactory.deployed()
      boxId = 2
    })

    it("mints game item id 2", async () => {
      await lootbox.mint(userB, boxId, 1, '0x')
      await lootbox.setFactoryForOption(boxId, fixLvlCharFactory.address)
      await lootbox.setProbabilitiesForOption(boxId, [10000])
      let tx = await lootbox.unpack(boxId, 1, {from: userB})
      const blockNumber = tx.receipt.blockNumber
      const events = await badge.getPastEvents("TransferSingle", {fromBlock: blockNumber, toBlock: blockNumber})
      let optionId = events[0].args.id.toNumber()
      assert.equal(optionId, 2)
    })

    it("mints level 1 character", async () => {
      await lootbox.mint(userB, boxId, 1, '0x')
      await lootbox.setFactoryForOption(boxId, fixLvlCharFactory.address)
      await lootbox.setProbabilitiesForOption(boxId, [0, 10000])
      let tx = await lootbox.unpack(boxId, 1, {from: userB})
      const blockNumber = tx.receipt.blockNumber
      const events = await cyborg.getPastEvents("Transfer", {fromBlock: blockNumber, toBlock: blockNumber})

      let tokenId = events[0].args.tokenId.toNumber()
      assert.isTrue(tokenId.toString().startsWith("1"))
    })
  })
})
