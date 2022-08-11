const { ChainIDPrefixes } = require("../lib/valuesCommon");
const Cyborg = artifacts.require('Cyborg');

module.exports = async function (deployer, network) {
    await deployer.deploy(Cyborg, ChainIDPrefixes[network])
};
