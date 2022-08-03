// https://rinkeby.etherscan.io/address/0x812398f74eAd4031DFA05C9f2D0280Ee704C8AFe#code

import {
	developmentChains,
	VERIFICATION_BLOCK_CONFIRMATIONS,
	networkConfig,
} from '../helper-hardhat-config'
import verify from '../utils/verify'
import { DeployFunction } from 'hardhat-deploy/types'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { storeImages, storeTokeUriMetadata } from '../utils/uploadToPinata'

const FUND_AMOUNT = '1000000000000000000000' // 10 LINK
const imagesLocation = './images/randomNft/'
// let tokenUris = [
//     "ipfs://QmaVkBn2tKmjbhphU7eyztbvSQU5EXDdqRyXZtRhSGgJGo",
//     "ipfs://QmYQC5aGZu2PTH8XzbJrbDnvhj3gVs7ya33H9mqUNvST3d",
//     "ipfs://QmZYmH5iDbD6v3U2ixoVAjioSzvWJszDzYdbeCLquGSpVm",
// ]

const metadataTemplate = {
	name: '',
	description: '',
	image: '',
	attributes: [
		{
			trait_type: 'Cuteness',
			value: 100,
		},
	],
}

const deployRandomIpfsNft: DeployFunction = async function (
	hre: HardhatRuntimeEnvironment
) {
	const { deployments, getNamedAccounts, network, ethers } = hre
	const { deploy, log } = deployments
	const { deployer } = await getNamedAccounts()

	let tokenUris = []
	if (process.env.UPLOAD_TO_PINATA === 'true') {
		tokenUris = await handleTokenUris()
	}

	const chainId = network.config.chainId!

	let vrfCoordinatorV2Address = ''
	let subscriptionId = ''

	if (developmentChains.includes(network.name)) {
		const vrfCoordinatorV2Mock = await ethers.getContract(
			'VRFCoordinatorV2Mock'
		)
		vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address
		const tx = await vrfCoordinatorV2Mock.createSubscription()
		const txReceipt = await tx.wait(1)
		subscriptionId = txReceipt.events[0].args.subId
        await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, FUND_AMOUNT)
	} else {
		vrfCoordinatorV2Address = networkConfig[chainId].vrfCoordinatorV2!
		subscriptionId = networkConfig[chainId].subscriptionId!
	}

	log('----------------------------------------------------')

	log('store images in IPFS')
	// await storeImages(imagesLocation)

	const args: any[] = [
		vrfCoordinatorV2Address,
		subscriptionId,
		networkConfig[chainId].gasLane!,
		networkConfig[chainId].callbackGasLimit!,
		tokenUris,
        networkConfig[chainId].mintFee!,
	]

    const waitBlockConfirmations = developmentChains.includes(network.name)
    ? 1
    : VERIFICATION_BLOCK_CONFIRMATIONS

    // deploy
    console.log("deploying RandomIpfsNft...")
    const randomIpfsNft = await deploy('RandomIpfsNft',{
        from: deployer,
        args,
        log: true,
        waitConfirmations: waitBlockConfirmations || 1,
    })
    console.log("RandomIpfsNft deployed at: ", randomIpfsNft.address)

    // verify
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...")
        await verify(randomIpfsNft.address, args)
        log("Verified! ", randomIpfsNft.address)
    }
}

async function handleTokenUris() {
	let tokenUris: any[] = []
	// // store the Image in IPFS
	const { responses: imageUploadResponse, files } = await storeImages(
		imagesLocation
	)
	for (let imageUploadResponseIndex in imageUploadResponse) {
		let tokenUriMetadata = { ...metadataTemplate }
		tokenUriMetadata.name = files[imageUploadResponseIndex].replace(
			'.png',
			''
		)
		tokenUriMetadata.description = `An adorable ${tokenUriMetadata.name} pup!`
		tokenUriMetadata.image = `ipfs://${imageUploadResponse[imageUploadResponseIndex].IpfsHash}`
		console.log(`Uploading ${tokenUriMetadata.name}...`)
		const metadataUploadResponse = await storeTokeUriMetadata(
			tokenUriMetadata
		)
		tokenUris.push(`ipfs://${metadataUploadResponse!.IpfsHash}`)
	}
	console.log('token uris: ', tokenUris)
	return tokenUris
}

export default deployRandomIpfsNft

deployRandomIpfsNft.tags = ['all', 'randomipfs', 'main']
