const BlindBoxFactory = artifacts.require("BlindBoxFactory");
const BlindBox = artifacts.require("BlindBox");

contract("BlindBoxFactory", function ([owner, userA]) {
  let bb;
  beforeEach(async () => {
    bb = await BlindBoxFactory.deployed();
  })

  it("adds new option", async function () {
    return assert.isTrue(true);
  })

  it("grants minter role to BlindBox instances", async () => {
  })

  it("unpacks BlindBox", async () => {

  })

  it("returns all existing BlindBox addresses", async () => {

  })

  it("configures consumerable factory", async () => {

  })
});
