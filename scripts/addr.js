const CyberpopBadge = artifacts.require('CyberpopBadge');

module.exports = function(callback) {
  console.log("CyberpopBadge contract address:");
  console.log(CyberpopBadge.address);
  callback()
}
