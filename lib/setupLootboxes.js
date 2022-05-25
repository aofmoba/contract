// Grant MINTER_ROLE to LootBox contract on factories
const grantMinter = async (operator, asset) => {
    const minter = await asset.MINTER_ROLE()
    await asset.grantRole(minter, operator.address)
}

module.exports = {
  grantMinter,
};
