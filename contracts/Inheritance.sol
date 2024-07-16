// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


contract Ownable {
    address public owner;
    constructor(address ownerOverride){
        owner = ownerOverride == address(0) ? msg.sender : ownerOverride;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Not the owner!");
        _;
    }

}

abstract contract Balances is Ownable {
    function getBalance() public view onlyOwner returns(uint) {
        return address(this).balance;
    }

    function withdraw(address payable _to) public onlyOwner {
        _to.transfer(address(this).balance);
    }
}

contract Inheritance is Ownable, Balances {
    
}
