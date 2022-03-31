const CyberClub = artifacts.require("CyberClub");
const Cyborg = artifacts.require("Cyborg");
const CyberPopBadge = artifacts.require("CyberPopBadge");
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

  //const club = await CyberClub.deployed()
  //const badge = await CyberPopBadge.deployed()
  //const cyborg = await Cyborg.deployed()

  const club = await CyberClub.at('0x..')
  const badge = await CyberPopBadge.at('0x..')
  const cyborg = await Cyborg.at('0x..')

  await deployer.deploy(CyberClubFactory, club.address, lootbox.address, badge.address)
  await deployer.deploy(CharacterFactory, cyborg.address)

  const charFactory = await CharacterFactory.deployed()
  let minter = await cyborg.MINTER_ROLE()
  await cyborg.grantRole(minter, charFactory.address);

  const cyberClubFactory = await CyberClubFactory.deployed()

  // minter = await badge.MINTER_ROLE()
  // await badge.grantRole(minter, cyberClubFactory.address);

  minter = await club.MINTER_ROLE()
  await club.grantRole(minter, cyberClubFactory.address);

  await setupLootBox(lootbox, cyberClubFactory, charFactory);
};
