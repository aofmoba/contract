const CyberpopGame = artifacts.require("CyberpopGame");
const ConsumerableFactory = artifacts.require("ConsumerableFactory");
const LootBox = artifacts.require("LootBox");
const { setupConsumerableFactory } = require("../lib/setupLootboxes");

module.exports = async (deployer, network, accounts) => {
  const badge = await CyberpopGame.deployed()
  // const badge = await CyberpopGame.at('0x..')

  await deployer.deploy(ConsumerableFactory, badge.address, [2, 101101, 3, 4])

  const consumerableFactory = await ConsumerableFactory.deployed()
  await badge.grantRole(minter, consumerableFactory.address)

  const lootbox = await LootBox.deployed()
  setupConsumerableFactory(lootbox, consumerableFactory)
};
