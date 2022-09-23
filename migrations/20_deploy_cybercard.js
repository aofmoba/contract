const GamePlayToken = artifacts.require('GamePlayToken');

module.exports = async function (deployer, network) {
    await deployer.deploy(GamePlayToken)
};
