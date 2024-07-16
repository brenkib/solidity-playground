// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Functions {

    // public, external, internal, private

    // view, pure

    function getBalance() public view returns(uint balance){
        balance = address(this).balance;
    }

    /*function getBalanceExternal() external {

    }

    function getBalanceInternal() internal {

    }*/
}
