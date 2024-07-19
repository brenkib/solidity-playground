// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Demo7 {

    event Paid(address indexed _from, uint _amount, uint _time);
    function pay() public payable {
        emit Paid(msg.sender, msg.value, block.timestamp);
    }

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        pay();
    }

    modifier onlyOwner(address _to) {
        require(msg.sender == owner, "Not owner");
        require(_to != address(0), "0x0 address");
        _;
    }

    function withdraw(address payable _to) external onlyOwner(_to) {

        // PANIC
        //assert(msg.sender == owner);

        //require(msg.sender == owner, "Not owner");

        //if (msg.sender != owner) {
        //    revert("Not owner");
        //}

        _to.transfer(address(this).balance);
    }
}