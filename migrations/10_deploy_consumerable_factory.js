const CyberpopGame = artifacts.require("CyberpopGame");
const ConsumerableFactory = artifacts.require("ConsumerableFactory");
const { grantMinter } = require("../lib/setupLootboxes");

module.exports = async (deployer, network, accounts) => {
  const badge = await CyberpopGame.deployed()
  // const badge = await CyberpopGame.at('0x..')

  await deployer.deploy(ConsumerableFactory, badge.address,
    [
      // 消耗品
      2, 101101, 3, 4,
      // 支援卡
      10, 11, 12, 13,
      14, 15, 16, 17
    ])
  const consumerableFactory = await ConsumerableFactory.deployed()

  await grantMinter(consumerableFactory, badge)
};
