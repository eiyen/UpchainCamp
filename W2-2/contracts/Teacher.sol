// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IScore.sol";
import "./Score.sol";

contract Teacher {
    
    IScore private scoreContract;

    constructor(address scoreContractAddress) {
        scoreContract = IScore(scoreContractAddress);
    }

    function viewStudentScore(address student) public view returns (uint256) {
        return scoreContract.getScore(student);
    }

    function setStudentScore(address student, uint256 score) public {
        scoreContract.setScore(student, score);
    }
}