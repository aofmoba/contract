const CYT = artifacts.require('CyberPopToken');

const { deployProxy } = require('@openzeppelin/truffle-upgrades');

module.exports = async function (deployer) {
    await deployProxy(CYT, [], { deployer, kind: "uups" });
};