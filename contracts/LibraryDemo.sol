// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library StrComparison{
    function eq(string memory str1, string memory str2) internal pure returns(bool)  {
        return keccak256(abi.encode(str1)) == keccak256(abi.encode(str2));
    }
}

library ArrayExt {
    function inArray(uint[] memory arr, uint el) internal pure returns(bool)  {
        for(uint i = 0; i < arr.length; i++) {
            if(arr[i] == el) {
                return true;
            }
        }
        return false;
    }
}

contract LibraryDemo {
    using StrComparison for string;
    using ArrayExt for uint[];
    function runnerStr(string memory str1, string memory str2) public pure returns(bool)  {
        return str1.eq(str2);
    }

    function runnerArr(uint[] memory array, uint element) public pure returns(bool)  {
        return array.inArray(element);
    }
    constructor(){

    }
}
