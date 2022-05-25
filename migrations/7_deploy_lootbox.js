const LootBox = artifacts.require("LootBox");
const LootBoxRandomness = artifacts.require("LootBoxRandomness");

module.exports = async (deployer, network, accounts) => {
    await deployer.deploy(LootBoxRandomness);
    await deployer.link(LootBoxRandomness, LootBox);
    await deployer.deploy(LootBox)
};
