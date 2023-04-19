// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract MyERC20V1 is ERC20Upgradeable {
    function initialize() initializer external {
        __ERC20_init("MyERC20", "MER");
        _mint(msg.sender, 1000e18);
    }
}