const ChainIDPrefixes = {
    // testnet
    fuji: 0,
    rinkeby: 10000, 
    bsct: 20000,
    mumbai: 30000,
    // production
    avax: 40000,
    mainnet: 50000, // Ethereum
    bsc: 60000,
    polygon: 70000,
    heco: 80000,
    gate: 90000,

    // local, ignore
    development: 0,
    geth: 10000
}

module.exports = {
    ChainIDPrefixes,
};
