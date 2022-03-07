const CyberPopToken = artifacts.require('CyberPopToken');

module.exports = async function (deployer) {
  await deployer.deploy(CyberPopToken)
};
