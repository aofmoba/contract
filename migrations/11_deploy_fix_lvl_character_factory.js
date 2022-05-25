const ConsumerableFactory = artifacts.require("ConsumerableFactory");
const CharacterFactory = artifacts.require("CharacterFactory");
const FixLvlCharFactory = artifacts.require("FixLvlCharFactory");
const LootBox = artifacts.require("LootBox");
const { grantMinter } = require("../lib/setupLootboxes");

module.exports = async (deployer, network, accounts) => {
    const lootbox = await LootBox.deployed()
    const characterFactory = await CharacterFactory.deployed()
    const consumerableFactory = await ConsumerableFactory.deployed()

    const numOptions = 4
    await deployer.deploy(FixLvlCharFactory, consumerableFactory.address, characterFactory.address, numOptions)
    const fixLvlCharFactory = await FixLvlCharFactory.deployed()

    await grantMinter(fixLvlCharFactory, characterFactory)
    await grantMinter(fixLvlCharFactory, consumerableFactory)
    await grantMinter(lootbox, fixLvlCharFactory)
};
