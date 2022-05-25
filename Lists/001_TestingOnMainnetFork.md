# Testing on mainnet fork with ganache-cli

I. Install ganache client
`npm install ganache-cli` or
`npm install -g ganache-cli` for global installation

II. Get infura endpoint from the mainnet
`https://mainnet.infura.io/v3/{projectID}`

III. Find an address with tokens you need
`ETH 0x4E48191DbCd0Ebe2415bae3e13C23e8E71f4dB76`

IV. Fork mainnet and unlock account with tokens you need
`ganache-cli --fork https://mainnet.infura.io/v3/{projectID} --unlock 0x4E48191DbCd0Ebe2415bae3e13C23e8E71f4dB76`

V. Write the network fork into the truffle-config.js
```
    mainnetFork: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "1",       // Any network (default: none)
      },
```
