const CyberClubFactory = artifacts.require("CyberClubFactory");
const CharacterFactory = artifacts.require("CharacterFactory");
const ConsumerableFactory = artifacts.require("ConsumerableFactory");
const LootBox = artifacts.require("LootBox");
const LootBoxRandomness = artifacts.require("LootBoxRandomness");

const { setupLootBox } = require("../lib/setupLootboxes");

module.exports = async (deployer, network, accounts) => {
    await deployer.deploy(LootBoxRandomness);
    await deployer.link(LootBoxRandomness, LootBox);
    await deployer.deploy(LootBox)
    const lootbox = await LootBox.deployed()

    // const club = await CyberClub.at('0x..')
    // const badge = await CyberpopGame.at('0x..')
    // const cyborg = await Cyborg.at('0x..')

    const charFactory = await CharacterFactory.deployed()
    const cyberClubFactory = await CyberClubFactory.deployed()
    const consumerableFactory = await ConsumerableFactory.deployed()

    await setupLootBox(lootbox, cyberClubFactory, charFactory, consumerableFactory);
};
