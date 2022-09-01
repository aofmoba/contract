const CyberClubFactory = artifacts.require("CyberClubFactory");
const CharacterFactory = artifacts.require("CharacterFactory");
const ConsumerableFactory = artifacts.require("ConsumerableFactory");
const FixLvlCharFactory = artifacts.require("FixLvlCharFactory");
const CardFactory = artifacts.require("CardFactory");
const LootBox = artifacts.require("LootBox");

const { grantMinter } = require("../lib/setupLootboxes");

module.exports = async (deployer, network, accounts) => {
  const lootbox = await LootBox.deployed()
  const charFactory = await CharacterFactory.deployed()
  const clubFactory = await CyberClubFactory.deployed()
  const consumerableFactory = await ConsumerableFactory.deployed()
  const fixLvlCharFactory = await FixLvlCharFactory.deployed()

  let minter = await lootbox.MINTER_ROLE()
  await lootbox.grantRole(minter, clubFactory.address)
  await clubFactory.setLootBox(lootbox.address)

  await grantMinter(lootbox, clubFactory)
  await grantMinter(lootbox, charFactory)

  await lootbox.setState(
    0,
    1337
  );

  // ID 0-2
  let optionId = await lootbox.numOptions()
  await lootbox.addNewOption(clubFactory.address, [10000]);
  console.log(`CyberClub [10000] option ID:`, optionId++)
  await lootbox.addNewOption(clubFactory.address, [0, 500, 9500]);
  console.log(`CyberClub [0,500,9500] option ID:`, optionId++)
  await lootbox.addNewOption(charFactory.address, [300, 800, 2000, 3000, 2000, 1000, 500, 300, 100]);
  console.log(`Random level Char [300, 800, 2000, 3000, 2000, 1000, 500, 300, 100] option ID:`, optionId++)

  await grantMinter(lootbox, consumerableFactory)

  // 消耗品机率
  let consumerableProbabilities = [
    [8000, 0, 2000],
    [10000],
    [9000, 1000],
    [5000, 5000],
  ]

  // ID 3-6
  for (let i = 0; i < consumerableProbabilities.length; i++) {
    await lootbox.addNewOption(consumerableFactory.address, consumerableProbabilities[i]);
    console.log(`consumerable ${consumerableProbabilities[i]} option ID:`, optionId++)
  }

  // FixLvlCharFactory probabilities
  let probabilities = [
    [9000, 1000],
    [5000, 5000]
  ]

  // ID 7-8
  for (let i = 0; i < probabilities.length; i++) {
    await lootbox.addNewOption(fixLvlCharFactory.address, probabilities[i]);
    console.log(`FixedLevel ${probabilities[i]} option ID:`, optionId++)
  }
  
  // ID 9 以后待定
};
