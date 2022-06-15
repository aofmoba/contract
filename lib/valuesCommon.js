const ChainIDPrefixes = {
    // testnet
    fuji: 0,
    rinkeby: 1, 
    bsct: 2,
    mumbai: 3,
    // production
    avax: 4,
    mainnet: 5, // Ethereum
    bsc: 6,
    polygon: 7,
    heco: 8,
    gate: 9,

    // local, ignore
    development: 0,
    geth: 1
}

module.exports = {
    ChainIDPrefixes,
};
