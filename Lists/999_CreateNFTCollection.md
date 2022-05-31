## How to create an NFT collection based on ERC721 token Standard
- create a smart contract which contains the logic
- use decentralized storage Pinata (IPFS) to store the metadata and assets that the smart contract points to.

### Create the images and upload to Pinata (IPFS)  <br>
1. create the images with a name + rising counter
2. put them into one folder
3. upload folder to Pinata
4. save CID (content identifier)

### Create metadata .json file structure for each image
1. File structure
For further optional attributes cf. opensea metadata standard [here](https://docs.opensea.io/docs/metadata-standards)
```
{
  "name": "ElefanftVonHintenNFT",
  "description": "Elefant von hinten NFT Collection",
  "image": "ipfs://{folder CID}/{image0}.png",
  "attributes": [{"trait_type": "cool", "value": "yes"}]
}

```
2. Name the files 0, 1, ... for simplicity
3. put them into one folder
4. upload folder to Pinata
5. save CID (content identifier) with full URL, f.ex. <br>
` https://gateway.pinata.cloud/ipfs/{folder CID}/ ` -> last / is important!

### Create NFT smart contract - simple version
Imports
1. ERC721.sol           -> Basic NFT Standard
2. ERC721Enumerable.sol -> Extension to request information about # of NFTs
3. Ownable.sol          -> Verify and change ownership
4. SafeMath.sol         -> Library to avoid integer overflow

Example of simple smart contract [here](./999_CreateNFTCollection_simple.sol)



### Check on opensea under your account (the one who minted the NFT)
Opensea on Rinkeby testnet `https://testnets.opensea.io/ `
