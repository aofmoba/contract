const ADDR = "0x9ACB90810c3C57a62a1894a571Ed66dFebb5EFC0"
// the id of the badge to mint
const amount = 100;



module.exports = async(callback) => {
  let card = await CyberCard.deployed();
  for (var i=0; i<amount; i++)
  {
     await card.safeMint(ADDR);
     console.log("Minting...");
     console.log(i);
  }
  callback()
}
