//const Migrations = artifacts.require("Migrations");

const admin = "0x29C214d9dBa9D8F3D12bA335115DCeDc7b9FF1c6";
const price = 70;
const lootId =0 ;
const CyberpopGame = "0x10fde59432d1d6ee7ad25448e3d8b9b3d2c08b89"
const CyberPopToken= "0x55d398326f99059fF775485246999027B3197955";
const BoxPoolV2 = artifacts.require("BoxPoolV2");

//const tradingBsc = artifacts.require("tradingBsc"); 
module.exports = async function (deployer) { 
    // await deployer.deploy(CyberPopToken);
     //await deployer.deploy(CyberpopGame);
     await deployer.deploy(BoxPoolV2,admin,CyberpopGame,CyberPopToken,34);
};
