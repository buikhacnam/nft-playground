// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.1/contracts/token/ERC721/ERC721.sol
import "hardhat/console.sol";

/*
    - When we mint an NFT, Chainlink VRF will be triggered to get a random number.
    The random number will be used to generate a random IPFS hash.

    - Users have to pay to mint an NFT.

    - The owner of the contract can withdraw the ETH.

    *Notes:
        How to get a random number: https://docs.chain.link/docs/get-a-random-number/
*/

error AlreadyInitialized();
error NeedMoreETHSent();
error RangeOutOfBounds();
error TransferFailed();

contract RandomIpfsNft is VRFConsumerBaseV2, ERC721URIStorage, Ownable {
    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD0
    }

    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    mapping(uint256 => address) public s_requestIdToSender;

    uint256 public s_tokenCounter;
    uint256 internal constant MAX_CHANCE_VALUE = 100;
    string[] internal s_dogTokenUris;
    uint256 internal immutable i_mintFee;

    event NftRequested(uint256 indexed requestId, address requester);
    event NftMinted(Breed breed, address minter);

    constructor(
        address vrfCoordinatorV2,
        uint64 subscriptionId,
        bytes32 gasLane, // keyHash
        uint32 callbackGasLimit,
        string[3] memory dogTokenUris,
        uint256 mintFee
    )
        VRFConsumerBaseV2(vrfCoordinatorV2)
        ERC721("Random IPFS NFT", "RANDOMDOG")
    {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_subscriptionId = subscriptionId;
        i_gasLane = gasLane;
        i_callbackGasLimit = callbackGasLimit;

        s_dogTokenUris = dogTokenUris;
        i_mintFee = mintFee;
    }

    function requestNft() public payable returns (uint256 requestId) {
        // check if there is enough ETH to pay for the request
        if (msg.value < i_mintFee) {
            revert NeedMoreETHSent();
        }

        // request a random number
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        console.log("requestId: ", requestId);

        s_requestIdToSender[requestId] = msg.sender;

        emit NftRequested(requestId, msg.sender);
    }

    // this will be called by the VRF coordinator when the random number is ready
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        address dogOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter = s_tokenCounter + 1;

        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE; // moddedRng is a random number between 0 and 100
        Breed dogBreed = getBreedFromModdedRng(moddedRng); // dogBeed value is a Breed enum value
        _safeMint(dogOwner, newTokenId);
        _setTokenURI(newTokenId, s_dogTokenUris[uint256(dogBreed)]);

        emit NftMinted(dogBreed, dogOwner);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }
    }

    function getBreedFromModdedRng(uint256 moddedRng)
        public
        pure
        returns (
            Breed
        )
    {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArracy = getChanceArray();
        for (uint256 i = 0; i < chanceArracy.length; i++) {
            if (
                moddedRng >= cumulativeSum &&
                moddedRng < cumulativeSum + chanceArracy[i]
            ) {
                return Breed(i);
            }
            cumulativeSum = cumulativeSum + chanceArracy[i];
        }
        revert RangeOutOfBounds();
    }

    function getChanceArray() public pure returns (uint256[3] memory) {
        return [10, 30, MAX_CHANCE_VALUE];

        // from 0 to 10 -> dog1: 10%
        // from 10 to 30 -> dog2: 20%
        // from 30 to 100 -> dog3: 60%
    }

    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }

     function getDogTokenUris(uint256 index) public view returns (string memory) {
        return s_dogTokenUris[index];
    }

    // function getInitialized() public view returns (bool) {
    //     return s_initialized;
    // }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function seeBreed(uint256 i) public pure returns (Breed) {
        return Breed(i);
    }

    function seeDogTokenUris(uint256 i) public view returns (string memory) {
        Breed dogBreed = Breed(i);
        return s_dogTokenUris[uint256(dogBreed)];
    }
}
