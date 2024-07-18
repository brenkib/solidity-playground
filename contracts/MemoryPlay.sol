// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract MemoryPlay {

    function work(uint[3] memory _str) external pure returns(bytes32 data) {
        assembly {
            let prt := mload(64) // ptr 192
            // 192 - 32 -> _str
            data := mload(sub(ptr, 96)) // access _str[0]
        }
        return data;
    }
    constructor(){

    }
}

contract MemoryPlay2 {

    function selector() external pure returns(bytes4) {
        return bytes4(keccak256(bytes("work(uint256[3])"))); //bytes4: 0x1c28968b
    }
    function work(uint[3] memory _str) external pure returns(bytes memory) {
        return msg.data; // bytes: 0x1c28968b000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003
    }
    constructor(){

    }
}
