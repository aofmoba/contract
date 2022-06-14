const TimeLock = artifacts.require('TimeLock');
const CyberpopToken = artifacts.require('CyberpopToken');

module.exports = async function (deployer) {
    await deployer.deploy(TimeLock, CyberpopToken.address);
};
