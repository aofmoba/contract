const CyberpopGame = artifacts.require('CyberpopGame');

module.exports = async function (deployer) {
    await deployer.deploy(CyberpopGame);
};
