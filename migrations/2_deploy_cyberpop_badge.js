const CyberPopBadge = artifacts.require('CyberPopBadge');

const { deployProxy } = require('@openzeppelin/truffle-upgrades');

module.exports = async function (deployer) {
    await deployProxy(CyberPopBadge, [], { deployer, kind: "uups" });
};