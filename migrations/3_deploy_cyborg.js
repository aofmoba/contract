const Cyborg = artifacts.require('Cyborg');

const { deployProxy } = require('@openzeppelin/truffle-upgrades');

module.exports = async function (deployer) {
    await deployProxy(Cyborg, [], { deployer, kind: "uups" });
};