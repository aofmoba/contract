const ConsumerableFactory = artifacts.require("ConsumerableFactory");
const CharacterFactory = artifacts.require("CharacterFactory");
const FixLvlCharFactory = artifacts.require("FixLvlCharFactory");
const LootBox = artifacts.require("LootBox");

module.exports = async (deployer, network, accounts) => {
    const characterFactory = await CharacterFactory.deployed()
    const consumerableFactory = await ConsumerableFactory.deployed()

    await deployer.deploy(FixLvlCharFactory, consumerableFactory.address, characterFactory.address)
    const fixLvlCharFactory = await FixLvlCharFactory.deployed()

    let minter = await characterFactory.MINTER_ROLE()
    await characterFactory.grantRole(minter, fixLvlCharFactory.address)

    minter = await consumerableFactory.MINTER_ROLE()
    await consumerableFactory.grantRole(minter, fixLvlCharFactory.address)

    const lootbox = await LootBox.deployed()
    lootbox.addNewOption(fixLvlCharFactory.address, [9000, 1000])
    lootbox.addNewOption(fixLvlCharFactory.address, [5000, 5000])
};
