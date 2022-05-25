const ConsumerableFactory = artifacts.require("ConsumerableFactory");
const CharacterFactory = artifacts.require("CharacterFactory");
const FixLvlCharFactory = artifacts.require("FixLvlCharFactory");
const LootBox = artifacts.require("LootBox");

module.exports = async (deployer, network, accounts) => {
    const characterFactory = await CharacterFactory.deployed()
    const consumerableFactory = await ConsumerableFactory.deployed()

    const numOptions = 3
    await deployer.deploy(FixLvlCharFactory, consumerableFactory.address, characterFactory.address, numOptions)
    const fixLvlCharFactory = await FixLvlCharFactory.deployed()

    let minter = await characterFactory.MINTER_ROLE()
    await characterFactory.grantRole(minter, fixLvlCharFactory.address)

    minter = await consumerableFactory.MINTER_ROLE()
    await consumerableFactory.grantRole(minter, fixLvlCharFactory.address)

    const lootbox = await LootBox.deployed()
    let optionId = await lootbox.numOptions()
    // ID 7
    await lootbox.addNewOption(fixLvlCharFactory.address, [9000, 1000])
    console.log('Fixed level [9000, 1000] option ID:', optionId++)
    // ID 8
    await lootbox.addNewOption(fixLvlCharFactory.address, [5000, 5000])
    console.log('Fixed level [5000, 5000] option ID:', optionId++)
    // ID 9
    await lootbox.addNewOption(fixLvlCharFactory.address, [0, 800, 9000, 200])
    console.log('Fixed level [800, 9000, 200] option ID:', optionId++)

    minter = await fixLvlCharFactory.MINTER_ROLE()
    await fixLvlCharFactory.grantRole(minter, lootbox.address)
};
