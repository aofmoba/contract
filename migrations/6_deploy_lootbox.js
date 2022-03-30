const CyberClub = artifacts.require("CyberClub");
const Cyborg = artifacts.require("Cyborg");
const CyberPopBadge = artifacts.require("CyberPopBadge");
const CyberClubFactory = artifacts.require("CyberClubFactory");
const CharacterFactory = artifacts.require("CharacterFactory");
const LootBox = artifacts.require("LootBox");

const { setupLootBox } = require("../lib/setupLootboxes");

module.exports = async (deployer, network, accounts) => {
  await deployer.deploy(LootBox)
  const club = await CyberClub.deployed()
  const badge = await CyberPopBadge.deployed()
  const lootbox = await LootBox.deployed()
  const cyborg = await Cyborg.deployed()

  await deployer.deploy(CyberClubFactory, club.address, lootbox.address, badge.address)
  await deployer.deploy(CharacterFactory, cyborg.address)

  const charFactory = await CharacterFactory.deployed()
  const cyberClubFactory = await CyberClubFactory.deployed()

  const minter = await charFactory.MINTER_ROLE()
  await cyberClubFactory.transferOwner(lootbox.address)
  await cyberClubFactory.grantRole(minter, lootbox.address)

  await setupLootBox(lootbox, cyberClubFactory, charFactory);
};
