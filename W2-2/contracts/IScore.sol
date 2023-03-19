// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IScore{
    function getScore(address student) external view returns (uint256);
    function setScore(address student, uint256 newScore) external; 
    event ScoreSet(address indexed student, uint256 score);
}