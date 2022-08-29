const CyberCard = artifacts.require("CyberCard");
const CardFactory = artifacts.require('CardFactory');
const { grantMinter } = require("../lib/setupLootboxes");
const LootBox = artifacts.require("LootBox");


module.exports = async (deployer, network, accounts) => {
  const card = await CyberCard.deployed()
  //const card = await CyberCard.at('0x47ac1c7249d087C01B2765452a0bFC36Bd561a03')
  await deployer.deploy(CardFactory, card.address)
  const cardFactory = await CardFactory.deployed()
  const lootbox = await LootBox.deployed()


  await grantMinter(cardFactory, card)
  await grantMinter(lootbox, cardFactory)
};
