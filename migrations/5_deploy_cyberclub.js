const CyberClub = artifacts.require('CyberClub')

module.exports = async function (deployer /*, accounts */) {
    // deploy CyberClub
    await deployer.deploy(CyberClub)
};
