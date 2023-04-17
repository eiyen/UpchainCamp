// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ICallbackReceiver {
    function onTokenTransfer(address from, address to, uint256 amount) external returns (bool);
}

contract TokenVaultWithCallback is Ownable {
    mapping(address => uint256) private _balances;
    IERC20 private _token;

    constructor(address tokenAddress) {
        _token = IERC20(tokenAddress);
    }

    function deposit(uint256 amount) external {
        _token.transferFrom(msg.sender, address(this), amount);
        _balances[msg.sender] += amount;
    }

    function token() public view returns (address) {
        return address(_token);
    }

    function withdraw(uint256 amount) external {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        _token.transfer(msg.sender, amount);
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    // function onTokenTransfer(address from, address to, uint256 amount) external returns (bool) {
    //     require(msg.sender == address(_token), "Invalid token address");
    //     _balances[to] += amount;
    //     return true;
    // }
}
