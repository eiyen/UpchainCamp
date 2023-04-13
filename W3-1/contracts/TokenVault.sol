// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Recipient.sol";

pragma solidity ^0.8.9;

contract TokenVault is Recipient {
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

    /**
     * NOTE:
     * 
     * 目的：比较 external 和 public 可见性的差异
     * 
     * 场景：仅有用户调用函数
     * 
     * 作用：
     * - external: 在外部调用时，会产生更少的 gas 费用。
     * - public: 在调用时，gas 费用高于 external 的外部调用，低于 external 的内部调用。
     * 
     * 结论：deposit 函数由于仅需被外部调用，因此使用 external 可见性更加合适。
     */

    /**
     * NOTE: 使用 _msgSender() 调用 msg.sender, 能够在 meta-transaction 也就是代付中，获取正确的用户地址。
     * 但是在当前场景下暂不考虑代付情况，所以 deposit 中直接使用 msg.sender 而非 _msgSender()
     */

    function deposit(uint256 amount) external {
        require(_token.transferFrom(msg.sender, address(this), amount), "Failed transaction");
        _balances[msg.sender] += amount;
    }

    function withdraw(uint256 amount) external {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        require(_token.transfer(msg.sender, amount), "Failed transaction");
    }

    function balanceOf() external view returns(uint256) {
        return _balances[msg.sender];
    }

    function token() external view returns(address) {
        return address(_token);
    }

    function tokensReceived(address sender, uint256 amount) external override returns(bool) {
        require(msg.sender == address(_token), "Invalid address");
        _balances[sender] += amount;
        return true;
    }
}