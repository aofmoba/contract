const classTokens = [
  [0], // 0 for always mint a cyber club card
  [1], // 5% probability to mint a card lootbox
  [2],
  // Character levels
  [1],
  [2],
  [3],
  [4],
  [5],
  [6],
  [7],
  [8],
  [9],
];

const classProbabilities = [
  [10000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 500, 9500, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [0, 0, 0, 300, 800, 2000, 3000, 2000, 1000, 500, 300, 100],
];

// Configure the lootbox

const setupLootBox = async (lootBox, clubFactory, charFactory) => {
  let minter = await clubFfactory.MINTER_ROLE()
  await clubFactory.grantRole(minter, lootbox.address);
  minter = await charFactory.MINTER_ROLE()
  await charFactory.grantRole(minter, lootbox.address)

  await lootBox.setState(
    classProbabilities.length,
    classTokens.length,
    1337
  );

  // We have one token id per rarity class.
  for (let i = 0; i < classTokens.length; i++) {
    await lootBox.setTokenIdsForClass(i, classTokens[i]);
    if (i < 3) {
      await lootBox.setFactoryForClass(i, clubFactory.address);
    } else {
      await lootBox.setFactoryForClass(i, charFactory.address);
    }
  }

  for (let i = 0; i < classProbabilities.length; i++) {
    await lootBox.setProbabilitiesForOption(i, classProbabilities[i]);
  }
};

module.exports = {
  setupLootBox,
};
