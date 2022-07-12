const BlindBoxFactory = artifacts.require('BlindBoxFactory');

const CyberpopGame = artifacts.require("CyberpopGame");
const GameItemFactory = artifacts.require("GameItemFactory");
const LootBoxRandomness = artifacts.require("LootBoxRandomness");
const { grantMinter } = require("../lib/setupLootboxes");

module.exports = async (deployer, network, accounts) => {
    const badge = await CyberpopGame.deployed()
    // const badge = await CyberpopGame.at('0x..')

    await deployer.deploy(GameItemFactory, badge.address,
        [
            101101, 101201, 101301, 101401,
            101102, 101202, 101302, 101411,
            101150, 101250, 101350, 101451
        ])
    const gameItemFactory = await GameItemFactory.deployed()
    await grantMinter(gameItemFactory, badge)

    await deployer.link(LootBoxRandomness, BlindBoxFactory);
    await deployer.deploy(BlindBoxFactory);

    let factory = await BlindBoxFactory.deployed()
    await grantMinter(factory, gameItemFactory)
    let optionId = 0

    let probabilities = [
        [0.125, 0.125, 0.125, 0.125, 0.05, 0.05, 0.05, 0.05, 0.005, 0.005, 0.005, 0.005],
        [0.15, 0.15, 0.15, 0.15, 0.0625, 0.0625, 0.0625, 0.0625, 0.015, 0.015, 0.015, 0.015],
        [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.075, 0.075, 0.075, 0.075]
    ]
    for (let i = 0; i < probabilities.length; i++) {
        await factory.addNewOption(gameItemFactory.address, probabilities[i].map(x => x * 10000));
        console.log(`gate.io box ${probabilities[i]} option ID:`, optionId++)
    }
};

