const EasyStaking = artifacts.require("EasyStaking");
const Sigmoid = artifacts.require("Sigmoid");
const CyberPopToken = artifacts.require("CyberPopToken");

module.exports = async (deployer, network, accounts) => {
    await deployer.deploy(Sigmoid);
    await deployer.link(Sigmoid, EasyStaking);
    await deployer.deploy(EasyStaking, accounts[1], CyberPopToken.address, accounts[3], 10_000, 3600 * 24 * 3, 3600 * 5, 1000_000, 75_000, 0, 10)
};
