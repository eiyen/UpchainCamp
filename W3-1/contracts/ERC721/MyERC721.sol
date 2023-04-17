// SPDX-License-Identifier: MIT
// SPDX-License-Identifier:
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyERC721 is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("Corror's NFTs", "CRT") {}

    function safeMint(address to, string memory tokenURI) external returns (uint256) {
        uint256 newTokenId = _tokenIds.current();

        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        _tokenIds.increment();
        return newTokenId;
    }
}