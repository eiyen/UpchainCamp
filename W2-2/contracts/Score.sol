// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IScore.sol";
import "./Teacher.sol";

contract Score is IScore {

    address public owner;
    mapping(address => uint) private scores;
    bytes32 private constant TEACHER_CONTRACT_SALT = keccak256("SCORE_CONTRACT_SALT");

    error OnlyOwner();
    error InvalidScore();
    error InvalidAddress();

    constructor() {
        address teacherContractAddress = deployTeacherUsingCreate2();
        owner = teacherContractAddress;
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
        emit ScoreSet(student, newScore);
    }

    function deployTeacherUsingCreate2() internal returns (address) {
        bytes memory bytecode = type(Teacher).creationCode;
        bytes32 salt = TEACHER_CONTRACT_SALT;

        address teacherContractAddress;
        assembly {
            teacherContractAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        if (teacherContractAddress == address(0)) revert InvalidAddress();
        return teacherContractAddress;
    }
}