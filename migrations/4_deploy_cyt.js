const CyberpopToken = artifacts.require('CyberpopToken');

module.exports = async function (deployer, network) {
    await deployer.deploy(CyberpopToken)
};
