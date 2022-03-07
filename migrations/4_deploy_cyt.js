const CyberPopToken = artifacts.require('CyberPopToken')
const TimeLock = artifacts.require('TimeLock')

module.exports = async function (deployer) {
  // deploy CYT token
  await deployer.deploy(CyberPopToken)
  let token = await CyberPopToken.deployed()
  let minter = await token.MINTER_ROLE();

  // deploy Time Lock
  await deployer.deploy(TimeLock, token.address)
  let lock = await TimeLock.deployed()

  // set TimeLock as minter
  await token.grantRole(minter, lock.address);
};
