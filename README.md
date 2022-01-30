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

Then replace add the infura project ID to the `.secret.json` file

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
