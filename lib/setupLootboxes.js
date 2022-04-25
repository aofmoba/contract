// 非同质盲盒概率设置
const classProbabilities = [
  [10000], // 总和１００００，同工厂要错开ＩＤ
  [0, 500, 9500],
  [300, 800, 2000, 3000, 2000, 1000, 500, 300, 100],
  [9500, 0, 0, 500],
  [10000],
  [9000, 1000],
  [5000, 5000],
  [9000, 0, 1000],
  [5000, 0, 5000],
];

// Configure the lootbox

const setupLootBox = async (lootBox, clubFactory, charFactory, consumerableFactory) => {
  let minter = await lootBox.MINTER_ROLE()
  await lootBox.grantRole(minter, clubFactory.address)
  await clubFactory.setLootBox(lootBox.address)

  minter = await clubFactory.MINTER_ROLE()
  await clubFactory.grantRole(minter, lootBox.address);
  minter = await charFactory.MINTER_ROLE()
  await charFactory.grantRole(minter, lootBox.address)

  minter = await consumerableFactory.MINTER_ROLE()
  await consumerableFactory.grantRole(minter, lootBox.address)


  await lootBox.setState(
    classProbabilities.length,
    1337
  );

  await lootBox.setFactoryForOption(0, clubFactory.address);
  await lootBox.setFactoryForOption(1, clubFactory.address);
  await lootBox.setFactoryForOption(2, charFactory.address);

  for (let i = 0; i < classProbabilities.length; i++) {
    await lootBox.setProbabilitiesForOption(i, classProbabilities[i]);
  }
};

module.exports = {
  setupLootBox,
};
