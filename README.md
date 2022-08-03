# NFT Playground

Read EIP-721: Non-Fungible Token Standard: https://eips.ethereum.org/EIPS/eip-721
## Basic NFT

Contract Address: https://rinkeby.etherscan.io/address/0xaAb9a1e5fBB310548Fb7ef7841289174236763fF#code

View it on Opensea: https://testnets.opensea.io/collection/dogie-z6gqzrl4j3

Install dependencies:

```
yarn add -D dotenv hardhat-deploy @nomiclabs/hardhat-ethers@npm:hardhat-deploy-ethers ethers @nomiclabs/hardhat-waffle hardhat-contract-sizer

```

```
yarn add @openzeppelin/contracts
```

OpenZepplin docs: https://docs.openzeppelin.com/contracts/4.x/


## Random IPFS NFT

Contract Address: https://rinkeby.etherscan.io/address/0x812398f74eAd4031DFA05C9f2D0280Ee704C8AFe#code

View it on Opensea: https://testnets.opensea.io/collection/random-ipfs-nft-3zacu0bbpg

Install chainlink to get random number:

```
yarn add -D @chainlink/contracts

```

We can either use `Nft Storage`, `Pinata` or `IPFS` to store our data.

Documentations:

-   Pinata: https://app.pinata.cloud/pinmanager
-   IPFS: https://ipfs.io/
-   Nft Storage: https://nft.storage/

How upload data to these platform:

Please check the file `utils/uploadToPinata.ts` and `utils/uploadToNftStorage.ts`

## Dynamic NFT

Contract Address: https://rinkeby.etherscan.io/address/0x2aBb9E5d9648dc64bf37aB5F5Ed11aCa20679C7E#code

View it on Opensea: https://testnets.opensea.io/collection/dynamic-svg-nft-b165m1a9hv

This nft will be stored on chain with dynamic image based on value sent when minting.

Install base64 dependency:

```
yarn add -D base64-sol
```


## Deploy on Rinkeby

first deploy all the contracts without minting: 
```
yarn hardhat deploy --network rinkeby --tags main
```

then mint the nft:

```
deploy contracts and mint: yarn hardhat deploy --tags mint --network rinkeby

```


## Some common commands

```
yarn hardhat deploy

yarn hardhat deploy --tags randomipfs,mocks
```
