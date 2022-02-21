const Cyborg = artifacts.require("Cyborg");
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Cyborg", function (accounts) {
  let cyborg;
  let minterRole;
  beforeEach(async () => {
    cyborg = await deployProxy(Cyborg)
    minterRole = await cyborg.MINTER_ROLE()
  })

  it("has access control", async function () {
    let owner = accounts[0]
    assert.isTrue(await cyborg.hasRole(minterRole.toString(), owner))

    let userA = accounts[1]
    assert.isFalse(await cyborg.hasRole(minterRole.toString(), userA))

    await cyborg.grantRole(minterRole.toString(), userA)
    assert.isTrue(await cyborg.hasRole(minterRole.toString(), userA))
  })

  it("mints specific token id", async () => {
    let minter = accounts[1]
    let userB = accounts[3]
    await cyborg.grantRole(minterRole.toString(), minter)

    let balance = await cyborg.balanceOf(userB)
    assert.equal(balance.toNumber(), 0)

    await cyborg.safeMint(userB, 100)
    balance = await cyborg.balanceOf(userB)
    assert.equal(balance.toNumber(), 1)

    let ownerOfToken = await cyborg.ownerOf(100)
    assert.equal(userB, ownerOfToken)
  })

  it("returns correct meta uri", async () => {
    let uri = await cyborg.tokenURI(100)
    assert.equal("https://api.cyberpop.online/server/100", uri)
  })
});
