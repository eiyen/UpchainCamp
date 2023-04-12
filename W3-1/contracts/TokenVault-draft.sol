// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenVault {
    IERC20 public myToken;
    mapping(address => uint256) public deposits;

    constructor(address corrorTokenAddress) {
        myToken = IERC20(corrorTokenAddress);
    }

    function deposit(uint256 amount) public {
        require(myToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        deposits[msg.sender] += amount;
    }

    function withdraw(uint256 amount) public {
        require(deposits[msg.sender] > amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        require(myToken.transfer(msg.sender, amount), "Transfer failed");
    }
}