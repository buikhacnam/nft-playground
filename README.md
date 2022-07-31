# NFT Playground

Read EIP-721: Non-Fungible Token Standard: https://eips.ethereum.org/EIPS/eip-721
## Basic NFT

Install dependencies:

```
yarn add -D dotenv hardhat-deploy @nomiclabs/hardhat-ethers@npm:hardhat-deploy-ethers ethers @nomiclabs/hardhat-waffle hardhat-contract-sizer

```

```
yarn add @openzeppelin/contracts
```

OpenZepplin docs: https://docs.openzeppelin.com/contracts/4.x/


## Random IPFS NFT

pros: it's cheap

cons: someone needs to pin our data


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

## Some common commands

```
yarn hardhat deploy

yarn hardhat deploy --tags randomipfs,mocks
```
