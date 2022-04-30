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
  [5000, 5000],
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
    classProbabilities.length,
    1337
  );

  await lootBox.setFactoryForOption(0, clubFactory.address);
  await lootBox.setFactoryForOption(1, clubFactory.address);
  await lootBox.setFactoryForOption(2, charFactory.address);
  for (let i = 0; i < 3; i++) {
    await lootBox.setProbabilitiesForOption(i, classProbabilities[i]);
  }
};

const setupConsumerableFactory = async (lootBox, consumerableFactory) => {
  minter = await consumerableFactory.MINTER_ROLE()
  await consumerableFactory.grantRole(minter, lootBox.address)

  for (let i = 3; i < classProbabilities.length; i++) {
    await lootBox.addNewOption(consumerableFactory.address, classProbabilities[i]);
  }
}

module.exports = {
  setupLootBox,
  setupConsumerableFactory,
};
