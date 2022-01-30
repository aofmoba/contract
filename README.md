# Setup

```
npm install -g truffle
npm install
```

## Mnemonic and Infura project ID

First create `.secret.json`

```
cp .secret.json.example .secret.json
```

Then change the infura project ID to the `.secret.json` file

# deploy

- Localhost

```
truffle deploy --network development
```

- Polygon Mumbai testnet

```
truffle deploy --network mumbai
```

# Check on opensea

[TestNet](https://testnet.opensea.io/get-listed)


# Misc scripts

- Display contract address

```
truffle exec scripts/addr.js --network mumbai
```

- Mint to address

```
ADDR=0xB03C52C465F0Fb2A7229A70xxxxxxxxxxxxxxxxx TOKEN_ID=1 truffle exec scripts/mint.js --network mumbai
```
