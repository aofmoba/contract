const CyberpopBadget = artifacts.require('CyberpopBadget');

// your address
const {ADDR, TOKEN_ID} = process.env;
// the id of the badge to mint
const amount = 50;

module.exports = async(callback) => {
  let badge = await CyberpopBadget.deployed();
  console.log("Minting...");
  await badge.mint(ADDR, TOKEN_ID, amount, '0x0');
  callback()
}
