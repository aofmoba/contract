const CyberpopGovernor = artifacts.require('CyberpopGovernor');
const CyberpopVotes = artifacts.require('CyberpopVotes');
const CyberpopToken = artifacts.require('CyberpopToken');

module.exports = async function (deployer) {
    await deployer.deploy(CyberpopVotes, CyberpopToken.address);
    await deployer.deploy(CyberpopGovernor, CyberpopVotes.address);
};
