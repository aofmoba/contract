const CyberpopGame = artifacts.require('CyberpopGame');

const { deployProxy } = require('@openzeppelin/truffle-upgrades');

module.exports = async function (deployer) {
    await deployProxy(CyberpopGame, [], { deployer, kind: "uups" });
};
