// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @dev IRecipient 接口是通过回调函数，来实现在无需授权的情况下，完成向目标合约的转账和记录。
 * 其效果类似于 ERC777Recipient 接口，但是所需参数更加简洁，方便开发者直接调用函数。
 */
interface IRecipient {
    function tokensReceived(address sender, uint256 amount) external returns(bool);
}