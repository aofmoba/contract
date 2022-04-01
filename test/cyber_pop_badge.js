const CyberpopGame = artifacts.require("CyberpopGame");
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const { expectRevert } = require("@openzeppelin/test-helpers");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("CyberpopGame", function (accounts) {
  let badge;
  let minterRole;
  before(async () => {
    badge = await deployProxy(CyberpopGame)
    minterRole = await badge.MINTER_ROLE()
  })

  it("returns correct uri", async () => {
    let uri = await badge.uri(1)
    assert.equal("https://api.cyberpop.online/badge/1", uri)
  })

  it("has access control", async () => {
    let owner = accounts[0]
    assert.isTrue(await badge.hasRole(minterRole.toString(), owner))

    let userA = accounts[1]
    assert.isFalse(await badge.hasRole(minterRole.toString(), userA))

    await badge.grantRole(minterRole.toString(), userA)
    assert.isTrue(await badge.hasRole(minterRole.toString(), userA))
  })

  it("mints", async () => {
    let userA = accounts[1]
    let balance = await badge.balanceOf(userA, 0)
    assert.equal(balance.toNumber(), 0)

    await badge.mint(userA, 0, 100, '0x')

    balance = await badge.balanceOf(userA, 0)
    assert.equal(balance.toNumber(), 100)
  })

  it("allows authorized account to burn tokens", async () => {
    let userA = accounts[2]
    let userB = accounts[3]
    await badge.mint(userA, 1, 10, "0x")

    await expectRevert(badge.burn(userA, 1, 10, { from: userB }), "ERC1155: caller is not authorized to burn token")

    let burner_role = await badge.BURNER_ROLE()
    await badge.grantRole(burner_role.toString(), userB)
    await badge.burn(userA, 1, 10, { from: userB })

    let balance = await badge.balanceOf(userA, 1)
    assert.equal(balance.toNumber(), 0)
  })

});
