const { ChainIDPrefixes } = require("../lib/valuesCommon");
const CyberCard = artifacts.require('CyberCard')

module.exports = async function (deployer, network) {
    // deploy CyberCard
    await deployer.deploy(CyberCard, 10000)
};
