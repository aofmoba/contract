const { ChainIDPrefixes } = require("../lib/valuesCommon");
const CyberClub = artifacts.require('CyberClub')

module.exports = async function (deployer, network) {
    // deploy CyberClub
    await deployer.deploy(CyberClub, ChainIDPrefixes[network])
};
