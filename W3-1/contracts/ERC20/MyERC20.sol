// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Recipient.sol";

contract MyERC20 is ERC20 {
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    /**
     * @dev 添加 transfer with callback 功能
     * @notice 无需通过 IERC777Recipient 接口实现该功能，
     * 因为接口要求函数传入 Data 等参数，在直接调用函数的场景下并不友好。
     */
    function transferWithCallback(address recipient, uint256 amount) external {
        transfer(recipient, amount);
        require(IRecipient(recipient).tokensReceived(msg.sender, amount), "Callback function failed");
    }
}