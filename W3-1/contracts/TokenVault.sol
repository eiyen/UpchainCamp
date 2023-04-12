// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity ^0.8.9;

contract TokenVault {
    mapping(address => uint256) private _balances;
    IERC20 private _token;

    constructor(address tokenAddress) {
        _token = IERC20(tokenAddress);
    }

    /** 
     * TODO: 
     * 1. 实现 deposit 函数，能够更新 _balances，使用 transferFrom 函数转账，并检查转账是否成功。
     * 2. 实现 withdraw 函数，能够检查目标地址是否合法，更新 _balances，使用 transfer 函数转账，并检查转账是否成功。
     * 3. 实现 balanceOf 函数，能够返回指定地址的余额
     * 4. 实现 token 函数，能够返回 _token 代币的地址
     * 5. 实现 onTokenTransfer 回调函数，能够在接收 ERC20 代币的转账后，更新 _balances
    */
}