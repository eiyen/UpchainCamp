// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IScore.sol";

contract Score is IScore {

    address public owner;
    mapping(address => uint) private scores;

    error OnlyOwner();
    error InvalidScore();

    constructor(address teacherAddress) {
        owner = teacherAddress;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    function getScore(address student) public view override returns (uint256) {
        return scores[student];
    }

    function setScore(address student, uint256 newScore) public override onlyOwner {
        if (newScore < 0 || newScore > 100) revert InvalidScore();
        scores[student] = newScore;
    }
}