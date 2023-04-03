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

    // 更新的功能，当用户在没有调用 deposit 的情况下进行转账时，自动执行该函数，记录用户转账数额
    function onTokenTransfer(address from, address to, uint256 amount) external returns (bool) {
        require(msg.sender == address(_token), "Invalid token address");
        _balances[to] += amount;
        return true;
    }

    // 数据迁移函数，将原先Vault合约中的金额，全部转移到当前的Vault合约中
    function migrateBalance(TokenVault tokenVault) external {
        uint256 balanceToMigrate = tokenVault.balanceOf(msg.sender);
        require(balanceToMigrate > 0, "No balance to migrate");
        tokenVault.withdraw(balanceToMigrate);
        _balances[msg.sender] += balanceToMigrate;
    }
}
