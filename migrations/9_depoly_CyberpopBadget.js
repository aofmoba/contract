const CyberpopBadget = artifacts.require('CyberpopBadget');

const { deployProxy } = require('@openzeppelin/truffle-upgrades');

module.exports = async function (deployer) {
    await deployProxy(CyberpopBadget, [], { deployer, kind: "uups" });
};
