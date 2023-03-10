// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Counter {
    uint256 public counter;

    function add(uint256 addNumber) public {
        counter += addNumber;
    }
}