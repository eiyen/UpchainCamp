// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Counter {
    uint256 public counter;

    function addCerternNumberToCounter(uint256 _addedNumber) public {
        counter += _addedNumber;
    }
}