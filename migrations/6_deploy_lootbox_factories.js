const CyberClub = artifacts.require("CyberClub");
const Cyborg = artifacts.require("Cyborg");
const CyberpopGame = artifacts.require("CyberpopGame");
const CyberClubFactory = artifacts.require("CyberClubFactory");
const CharacterFactory = artifacts.require("CharacterFactory");
const { ChainIDPrefixes } = require("../lib/valuesCommon");
const { grantMinter } = require("../lib/setupLootboxes");

module.exports = async (deployer, network, accounts) => {
  const club = await CyberClub.deployed()
  const badge = await CyberpopGame.deployed()
  const cyborg = await Cyborg.deployed()

  // const club = await CyberClub.at('0x..')
  // const badge = await CyberpopGame.at('0x..')
  // const cyborg = await Cyborg.at('0x..')

  await deployer.deploy(CyberClubFactory, club.address, badge.address)
  await deployer.deploy(CharacterFactory, cyborg.address, ChainIDPrefixes[network])

  const cyberClubFactory = await CyberClubFactory.deployed()
  const charFactory = await CharacterFactory.deployed()

  await grantMinter(charFactory, cyborg)
  await grantMinter(cyberClubFactory, badge)
  await grantMinter(cyberClubFactory, club)
};
