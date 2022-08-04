// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.7.1/contracts/token/ERC721/ERC721.sol
// import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BasicNftOnlyOwnerCanMint is ERC721, Ownable {
        string public constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    uint256 private s_tokenCounter;
    constructor() ERC721("Dogie", "DOG") {
        s_tokenCounter = 0;
    }

    // create new dog -> Call _safeMint()
    function mintNft() public onlyOwner returns(uint256) {
        /*
            _safeMint(address to, uint256 tokenId, bytes memory data)
                address to: address of the one who calls the function (will be the owner of the token)
                uint256 tokenId: token id
                bytes data: token data

        */
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
        return s_tokenCounter;
    }

    function tokenURI(uint256 /*tokenId*/) public pure override returns(string memory) {
        return TOKEN_URI;
    }

    function getTokenCounter() public view returns(uint256) {
        return s_tokenCounter;
    }
}