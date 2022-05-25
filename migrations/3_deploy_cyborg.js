const Cyborg = artifacts.require('Cyborg');

module.exports = async function (deployer) {
    await deployer.deploy(Cyborg);
};
