## Testing on mainnet fork with ganache-cli

### - Install ganache client <br>
`npm install ganache-cli` or
`npm install -g ganache-cli` for global installation

### - Get infura endpoint for mainnet <br>
`https://mainnet.infura.io/v3/{projectID}`

### - Find an address with tokens you need <br>
F.ex. ETH `0x4E48191DbCd0Ebe2415bae3e13C23e8E71f4dB76` <br>
Or find the creating address of a token and unlock. This address will be able to mint new tokens

### - Fork mainnet and unlock account with tokens you need <br>
`ganache-cli --fork https://mainnet.infura.io/v3/{projectID} --unlock 0x4E48191DbCd0Ebe2415bae3e13C23e8E71f4dB76`

### - Write the network fork into the truffle-config.js <br>
```
    mainnetFork: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "1",       // Any network (default: none)
      },
```
