const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const Badge = artifacts.require('CyberPopBadge');
const BadgeV2 = artifacts.require('CyberPopBadgeV2');

module.exports = async function (deployer) {
    const existing = await Badge.deployed();
    const instance = await upgradeProxy(existing.address, BadgeV2, { deployer });
    console.log("Upgraded", instance.address);
};
