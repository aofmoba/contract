const Cyborg = artifacts.require("Cyborg");
const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const { expectRevert } = require("@openzeppelin/test-helpers");

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

  it("allows authorized account to burn tokens", async () => {
    let userA = accounts[2]
    let userB = accounts[3]
    await cyborg.safeMint(userA, 1)

    await expectRevert(cyborg.burn(1, { from: userB }), "ERC721: caller is not authorized to burn token")

    let burner_role = await cyborg.BURNER_ROLE()
    await cyborg.grantRole(burner_role.toString(), userB)
    await cyborg.burn(1, { from: userB })

    await expectRevert(cyborg.ownerOf(1), "revert ERC721: owner query for nonexistent token")
  })
});
