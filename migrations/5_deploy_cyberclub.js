const CyberClub = artifacts.require('CyberClub')

module.exports = async function (deployer /*, accounts */) {
    // deploy CyberClub
    await deployer.deploy(CyberClub)
    let club = await CyberClub.deployed()

    const HOLDER = '0x47EA8219Cc2b646AC6a10Ae9E59a82CB2A103Ac9' // accounts[0]
    const NUM_TOKENS = 100
    // Batch mint to token holder
    console.log(`batch minting ${NUM_TOKENS} tokens...`)
    await club.batchMint(HOLDER, NUM_TOKENS);
};
