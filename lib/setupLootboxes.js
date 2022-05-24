// 非同质盲盒概率设置
const classProbabilities = [
  [10000], // 总和１００００，同工厂要错开ＩＤ
  [0, 500, 9500],
  // CharacterFactory
  [300, 800, 2000, 3000, 2000, 1000, 500, 300, 100],
  // ConsumerableFactory
  [8000, 0, 2000],
  [10000],
  [9000, 1000],
  [5000, 5000]
];

// Configure the lootbox

const setupLootBox = async (lootBox, clubFactory, charFactory) => {
    let minter = await lootBox.MINTER_ROLE()
    await lootBox.grantRole(minter, clubFactory.address)
    await clubFactory.setLootBox(lootBox.address)

    minter = await clubFactory.MINTER_ROLE()
    await clubFactory.grantRole(minter, lootBox.address);
    minter = await charFactory.MINTER_ROLE()
    await charFactory.grantRole(minter, lootBox.address)

    await lootBox.setState(
      0,
      1337
    );

    // ID 0-2
    let optionId = await lootBox.numOptions()
    await lootBox.addNewOption(clubFactory.address, classProbabilities[0]);
    console.log(`CyberClub ${classProbabilities[0]} option ID:`, optionId++)
    await lootBox.addNewOption(clubFactory.address, classProbabilities[1]);
    console.log(`CyberClub ${classProbabilities[1]} option ID:`, optionId++)
    await lootBox.addNewOption(charFactory.address, classProbabilities[2]);
    console.log(`Random level Char ${classProbabilities[2]} option ID:`, optionId++)
};

const setupConsumerableFactory = async (lootBox, consumerableFactory) => {
  minter = await consumerableFactory.MINTER_ROLE()
  await consumerableFactory.grantRole(minter, lootBox.address)

  // ID 3-6
  let optionId = await lootBox.numOptions()
  for (let i = 3; i < classProbabilities.length; i++) {
    await lootBox.addNewOption(consumerableFactory.address, classProbabilities[i]);
    console.log(`consumerable ${classProbabilities[i]} option ID:`, optionId++)
  }
}

module.exports = {
  setupLootBox,
  setupConsumerableFactory,
};
