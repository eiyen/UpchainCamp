// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract MyTokenWithCallback is ERC20, Ownable, ERC20Permit {
    constructor() ERC20("MyToken", "MTK") ERC20Permit("MyToken") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // 在不调用Vault合约中deposit函数的情况下，向Vault合约进行转账，同时能让合约记录转账
    function transferWithCallback(address recipient, uint256 amount) external returns (bool) {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(recipient != address(0), "Invalid recipient address");

        _transfer(_msgSender(), recipient, amount);

        ICallbackReceiver(msg.sender).onTokenTransfer(msg.sender, recipient, amount);
        return true;
    }
}