const CyberPopToken = artifacts.require('CyberPopToken');

module.exports = async function (deployer, network) {
    await deployer.deploy(CyberPopToken)
};
