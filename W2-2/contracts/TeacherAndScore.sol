// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IScore {
    function getScore(address student) external view returns (uint256);
    function setScore(address student, uint256 newScore) external;
    event ScoreSet(address indexed student, uint256 score);
}

contract Score is IScore {
    address public owner;
    mapping(address => uint) private scores;
    bytes32 private constant TEACHER_CONTRACT_SALT = keccak256("SCORE_CONTRACT_SALT");

    error OnlyOwner();
    error InvalidScore();
    error InvalidAddress();

    constructor() {
        owner = msg.sender;
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

    function deployTeacherUsingCreate2() public onlyOwner returns (address) {
        bytes32 salt = TEACHER_CONTRACT_SALT;
        bytes memory bytecode = abi.encodePacked(type(Teacher).creationCode, abi.encode(address(this)));
        
        address teacherContractAddress;
        assembly {
            teacherContractAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        if (teacherContractAddress == address(0)) revert InvalidAddress();
        owner = teacherContractAddress;
        return teacherContractAddress;
    }
}

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
