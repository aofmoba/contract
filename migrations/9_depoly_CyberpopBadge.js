const CyberpopBadge = artifacts.require('CyberpopBadge');

module.exports = async function (deployer) {
    await deployer.deploy(CyberpopBadge)
};
