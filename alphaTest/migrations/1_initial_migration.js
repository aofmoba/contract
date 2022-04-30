const Migrations = artifacts.require("Migrations");
const Coin = artifacts.require("Coin"); 
const GamePool = artifacts.require("GamePool");
const GameLogic = artifacts.require("GameLogic");
const game = "0xD4c27B5A5c15B1524FC909F0FE0d191C4e893695";
const role = "0x78F66E37e9fE077d2F0126E3a26e6FB0D14F2BB0";
const signer = "0xfd0cd49de3e8526fce2854b40d9f9ef9c74dfb0f";

module.exports = async function (deployer) { 
      await deployer.deploy(Coin);
      await  deployer.deploy(GamePool,signer,game,role,Coin.address,Coin.address);
      await  deployer.deploy(GameLogic,signer,game,role,GamePool.address);
      deployer.deploy(Migrations);
};
