// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "./IRecipient.sol";

contract MyERC20V2 is ERC20Upgradeable {
    
    using AddressUpgradeable for address;

    function transferWithCallback(address recipient, uint256 amount) external returns (bool) {
        require(transfer(recipient, amount), "Transfer failed");

        if (recipient.isContract()) {
            require(IRecipient(recipient).tokensReceived(msg.sender, amount), "Unprocessed transfer");
        }

        return true;
    }
}