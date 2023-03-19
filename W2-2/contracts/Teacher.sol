// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IScore.sol";
import "./Score.sol";

contract Teacher {
    
    IScore private scoreContract;
    bytes32 private constant SCORE_CONTRACT_SALT = keccak256("SCORE_CONTRACT_SALT");

    error InvalidAddress();

    constructor() {
        address scoreContractAddress = deployScoreUsingCreate2();
        scoreContract = IScore(scoreContractAddress);
    }

    function viewStudentScore(address student) public view returns (uint256) {
        return scoreContract.getScore(student);
    }

    function setStudentScore(address student, uint256 score) public {
        scoreContract.setScore(student, score);
    }

    function deployScoreUsingCreate2() internal returns (address) {
        bytes memory bytecode = type(Score).creationCode;
        bytes32 salt = SCORE_CONTRACT_SALT;

        address scoreContractAddress;
        assembly {
            scoreContractAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        if (scoreContractAddress == address(0)) revert InvalidAddress();
        return scoreContractAddress;
    }
}