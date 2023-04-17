// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTMarket is IERC721Receiver {
    /**
     * TODO:
     * 1. constructor(): 实现 MyERC20 和 MyERC721 合约地址的接收。
     * 2. list(): 将第 tokenId 个 NFT 以 Value 的价格通过 safeTransferFrom 的方式转账至该合约。
     * 3. buy(): 
     *  3.1 判断 value 是否为 0，从而判断是否已售出。
     *  3.2 判断 MyERC20 代币数量 amount 是否大于等于 value。
     *  3.3 将 amount 个 MyERC20 代币通过 transferFrom 转账至 tokenID 的 owner 手中。
     *  3.4 将第 tokenID 个 NFT 通过 transferFrom 转账至 msg.sender 手中。
     *  3.5 将 value 设置为 0.
     * 4. onERC721Received(): 返回该函数的 selector.
     */

    mapping(uint256 => uint256) private _tokenIdToPrice;
    address public immutable erc20TokenAddress;
    address public immutable erc721TokenAddress;

    constructor(address _erc20TokenAddress, address _erc721TokenAddress) {
        erc20TokenAddress = _erc20TokenAddress;
        erc721TokenAddress = _erc721TokenAddress;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function listNFTForSale(uint256 tokenId, uint256 price) external {
        require(price > 0, "Invalid price");
        IERC721(erc721TokenAddress).safeTransferFrom(msg.sender, address(this), tokenId);
        _tokenIdToPrice[tokenId] = price;
    }

    function getTokenPrice(uint256 tokenId) external view returns(uint256) {
        return _tokenIdToPrice[tokenId];
    }

    function buyNFT(uint256 tokenId) external {
        uint256 price = _tokenIdToPrice[tokenId];
        require(price > 0, "Token is not listed for sale");
        // CM: 
        // 为什么这里还需要判断所有权是否为本合约所有？
        // 当 price > 0 时不也就意味着它执行过了 listTokenForSale 中的 safeTransferFrom 了吗？
        require(IERC721(erc721TokenAddress).ownerOf(tokenId) == address(this), "Token is not available");

        // CM: 什么是重入攻击？为什么提前将价格设置为 0 能够防止重入攻击？
        _tokenIdToPrice[tokenId] = 0;

        IERC20(erc20TokenAddress).transferFrom(msg.sender, address(this), price);
        IERC721(erc721TokenAddress).safeTransferFrom(address(this), msg.sender, tokenId);
    }
}