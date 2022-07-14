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
            2, 101101, 101201, 101301, 101401,
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
        [0.24, 0.135, 0.135, 0.135, 0.135, 0.04, 0.04, 0.04, 0.04, 0.005, 0.005, 0.005, 0.005],
        [0.23, 0.04, 0.04, 0.04, 0.04, 0.13, 0.13, 0.13, 0.13, 0.012, 0.012, 0.012, 0.014],
        [0.03, 0.05, 0.05, 0.05, 0.05, 0.12, 0.12, 0.12, 0.11, 0.075, 0.075, 0.075, 0.075]
    ]
    for (let i = 0; i < probabilities.length; i++) {
        await factory.addNewOption(gameItemFactory.address, probabilities[i].map(x => x * 10000));
        console.log(`gate.io box ${probabilities[i]} option ID:`, optionId++)
    }
};

