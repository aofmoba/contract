const Cyborg = artifacts.require('Cyborg');
const CyborgV2 = artifacts.require('CyborgV2');

const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

module.exports = async function (deployer) {
  const existing = await Cyborg.deployed();
  const instance = await upgradeProxy(existing.address, CyborgV2, { deployer });
  console.log("Upgraded", instance.address);
};
