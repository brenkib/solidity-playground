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

    function withdraw(address payable _to) public virtual onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}

abstract contract Balances is Ownable {
    function getBalance() public view onlyOwner returns(uint) {
        return address(this).balance;
    }

    // private Not available in childs
    function withdraw(address payable _to) public virtual onlyOwner {
        _to.transfer(getBalance());
    }

}

contract Inheritance is Ownable, Balances {
    constructor (address _owner) Ownable(_owner) {

    }

    function withdraw(address payable _to) public override(Ownable, Balances) onlyOwner {
        //Balances.withdraw(_to);
        super.withdraw(_to); // super goes 1 level above in hierarchy
    }
}
