// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IScore.sol";

contract Score is IScore {

    address public owner;
    mapping(address => uint) private scores;

    constructor(address teacherAddress) {
        owner = teacherAddress;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function getScore(address student) public view override returns (uint256) {
        return scores[student];
    }

    function setScore(address student, uint256 newScore) public override onlyOwner {
        require(newScore >= 0 && newScore <= 100, "Score must be between 0 and 100");
        scores[student] = newScore;
    }
}