const CyberPopBadge = artifacts.require('CyberPopBadge');

module.exports = function(callback) {
  console.log("CyberPopBadge contract address:");
  console.log(CyberPopBadge.address);
  callback()
}
