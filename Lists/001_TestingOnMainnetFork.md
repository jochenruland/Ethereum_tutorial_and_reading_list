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
`ganache-cli --fork https://mainnet.infura.io/v3/{projectID} -p 7545 -i 999 -m "12 word mnemonic" -u 0x55e4d16f9c3041EfF17Ca32850662f3e9Dddbce7 0xb5b06a16621616875A6C2637948bF98eA57c58fa 0x9759A6Ac90977b93B58547b4A71c78317f391A28` <br>
Many options available. cf. `ganache-cli --fork --help` <br>
`-p` Port <br>
`-i` network_id <br>
`-m` mnemonic - using the same mnemonic will always create the same accounts which avoids new account imports to metamask in case of restarting the mainnet fork <br>
`-u` unlock account addresses (here for ether and Dai)

### - Import one or more of the accounts to metamask

### - Write the network fork into the truffle-config.js <br>
```
    mainnetFork: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 7545,            // Standard Ethereum port (default: none)
      network_id: "999",       // Any network (default: none)
      },
```

## Possible bugs and hurdles
- might have to restart the mainnet fork from time to time
- after restart you have to reset your corresponding accounts in metamask
