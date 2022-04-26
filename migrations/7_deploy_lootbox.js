const CyberClubFactory = artifacts.require("CyberClubFactory");
const CharacterFactory = artifacts.require("CharacterFactory");
const LootBox = artifacts.require("LootBox");
const LootBoxRandomness = artifacts.require("LootBoxRandomness");

const { setupLootBox } = require("../lib/setupLootboxes");

module.exports = async (deployer, network, accounts) => {
    await deployer.deploy(LootBoxRandomness);
    await deployer.link(LootBoxRandomness, LootBox);
    await deployer.deploy(LootBox)
    const lootbox = await LootBox.deployed()

    const charFactory = await CharacterFactory.deployed()
    const cyberClubFactory = await CyberClubFactory.deployed()

    await setupLootBox(lootbox, cyberClubFactory, charFactory);
};
