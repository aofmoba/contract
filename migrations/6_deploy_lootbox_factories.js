const CyberClub = artifacts.require("CyberClub");
const Cyborg = artifacts.require("Cyborg");
const CyberpopGame = artifacts.require("CyberpopGame");
const CyberClubFactory = artifacts.require("CyberClubFactory");
const CharacterFactory = artifacts.require("CharacterFactory");
const ConsumerableFactory = artifacts.require("ConsumerableFactory");
const { ChainIDPrefixes } = require("../lib/valuesCommon");

module.exports = async (deployer, network, accounts) => {
  const club = await CyberClub.deployed()
  const badge = await CyberpopGame.deployed()
  const cyborg = await Cyborg.deployed()

  // const club = await CyberClub.at('0x..')
  // const badge = await CyberpopGame.at('0x..')
  // const cyborg = await Cyborg.at('0x..')

  await deployer.deploy(CyberClubFactory, club.address, badge.address)
  await deployer.deploy(CharacterFactory, cyborg.address, ChainIDPrefixes[network])
  await deployer.deploy(CharacterFactory, badge.address, [2, 101101, 3, 4])

  const charFactory = await CharacterFactory.deployed()
  let minter = await cyborg.MINTER_ROLE()
  await cyborg.grantRole(minter, charFactory.address)

  const cyberClubFactory = await CyberClubFactory.deployed()

  minter = await badge.MINTER_ROLE()
  await badge.grantRole(minter, cyberClubFactory.address)

  const consumerableFactory = await ConsumerableFactory.deployed()
  await badge.grantRole(minter, consumerableFactory.address)

  minter = await club.MINTER_ROLE()
  await club.grantRole(minter, cyberClubFactory.address);
};
