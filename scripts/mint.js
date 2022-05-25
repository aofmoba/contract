const CyberpopBadge = artifacts.require('CyberpopBadge');

// your address
const {ADDR, TOKEN_ID} = process.env;
// the id of the badge to mint
const amount = 50;

module.exports = async(callback) => {
  let badge = await CyberpopBadge.deployed();
  console.log("Minting...");
  await badge.mint(ADDR, TOKEN_ID, amount, '0x0');
  callback()
}
