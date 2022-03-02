const CyberPopToken = artifacts.require('CyberPopToken');

module.exports = async function (deployer) {
  await deployer.deploy(CyberPopToken)
  //let bridge = '0xFd10eA2a062564f7E2EDb4e39CBCF3C956d29f40';
  //let cyt = await CyberPopToken.deployed();
  //let minterRole = await cyt.MINTER_ROLE();
  //await cyt.grantRole(minterRole, bridge);
};
