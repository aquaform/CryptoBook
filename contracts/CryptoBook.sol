// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Import this file to use console.log
import "hardhat/console.sol";

contract Contract {
    address public owner;
    string public telegram;
    string public discord;
    string public desc;

    constructor(string memory _telegram, string memory _discord) {
        owner = msg.sender;
        telegram = _telegram;
        discord = _discord;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setTelegram(string memory _telegram) public onlyOwner {
        telegram = _telegram;
    }

    function setDiscord(string memory _discord) public onlyOwner {
        discord = _discord;
    }

    function setDesc(string memory _desc) public onlyOwner {
        desc = _desc;
    }
}
