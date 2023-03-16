// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Bank {
    address payable private owner;
    mapping(address => uint256) private currentBalances;
    mapping(address => uint256) private totalBalances;
    address[] private users;

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function deposit() public payable {
        if (totalBalances[msg.sender] == 0) {
            users.push(msg.sender);
        }
        currentBalances[msg.sender] += msg.value;
        totalBalances[msg.sender] += msg.value;
    }

    function getMyCurrentBalance() public view returns (uint256) {
        return currentBalances[msg.sender];
    }

    function getMyTotalBalance() public view returns (uint256) {
        return totalBalances[msg.sender];
    }

    function getContributoryUser() public view returns (address[] memory) {
        return users;
    }

    function withdraw() public onlyOwner {
        owner.transfer(address(this).balance);
        for (uint256 i = 0; i < users.length; i++) {
            currentBalances[users[i]] = 0;
        }
    }
}