// https://rinkeby.etherscan.io/address/0x9B9Bc6F911f95d0ec2af69B80B7cAA41DEEc3503#code  

import {
	developmentChains,
	VERIFICATION_BLOCK_CONFIRMATIONS,
} from '../helper-hardhat-config'
import verify from '../utils/verify'
import { DeployFunction } from 'hardhat-deploy/types'
import { HardhatRuntimeEnvironment } from 'hardhat/types'

const deployOnlyOnwerCanMint: DeployFunction = async function (
	hre: HardhatRuntimeEnvironment
) {
	const { deployments, getNamedAccounts, network, ethers } = hre
	const { deploy, log } = deployments
	const { deployer } = await getNamedAccounts()
	const waitBlockConfirmations = developmentChains.includes(network.name)
		? 1
		: VERIFICATION_BLOCK_CONFIRMATIONS

	log('----------------------------------------------------')
	log('Deploying BasicNftOnlyOwnerCanMint From ' + network.name + '...')
	const args: any[] = []
	const basicNft = await deploy('BasicNftOnlyOwnerCanMint', {
		from: deployer,
		args: args,
		log: true,
		waitConfirmations: waitBlockConfirmations || 1,
	})

	// Verify the deployment
	if (
		!developmentChains.includes(network.name) &&
		process.env.ETHERSCAN_API_KEY
	) {
		log('Verifying...')
		await verify(basicNft.address, args)
	}
}

export default deployOnlyOnwerCanMint
deployOnlyOnwerCanMint.tags = ['all', 'deployOnlyOnwerCanMint', 'main']
