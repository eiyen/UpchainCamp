// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Counter {
    uint256 public counter;

    function add() public {
        counter += 1;
    }
}