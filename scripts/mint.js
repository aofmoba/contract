const CyberPopBadge = artifacts.require('CyberPopBadge');

// your address
const {ADDR, TOKEN_ID} = process.env;
// the id of the badge to mint
const amount = 5;

module.exports = async(callback) => {
  let badge = await CyberPopBadge.deployed();
  console.log("Minting...");
  await badge.mint(ADDR, TOKEN_ID, amount, '0x0');
  callback()
}
