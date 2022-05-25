const { expectRevert } = require("@openzeppelin/test-helpers");
const CyberPopToken = artifacts.require("CyberPopToken");

contract("CyberPopToken", function ([owner, userA]) {
  let cyt
  beforeEach(async () => {
    cyt = await CyberPopToken.deployed();
  })

  it("is capped", async () => {
    let totalSupply = await cyt.totalSupply()
    let cap = await cyt.CAP()
    assert.isTrue(totalSupply.eq(cap))
  })

  it("invokes onTokenTransfer callback on contracts", async () => {

  })
})
