const TimeLock = artifacts.require('TimeLock');
const CyberPopToken = artifacts.require('CyberPopToken');

module.exports = async function (deployer) {
    await deployer.deploy(TimeLock, CyberPopToken.address);
};
