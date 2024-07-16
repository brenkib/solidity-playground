// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Optimized {

    uint demo;

    // a & b grouped during init
    uint128 a = 1;
    uint128 b = 1;
    uint256 c = 1;

    // Uncut uint costs less gas
    uint demo2 = 1;


    // avoid temp variables if possible
    mapping(address => uint) payments;
    function pay() external payable {
        require(msg.sender != address(0), "Zero address");
        payments[msg.sender] = msg.value;
    } // total gas value 22334

    constructor(){

    }

    // BUT with arrays uint8 > uint because of data compression
    uint[] demoArray = [1,2,3];


    // Do not split function into smaller once's if possible
    uint calcVar = 5;
    uint d;
    function calc() public  {
        uint _a = 1+calcVar;
        uint _b = 2*calcVar;
        d = _a + _b;
    }
}

contract Unoptimized {
    uint demo = 0;

    // a & b NOT grouped during init
    uint128 a = 1;
    uint256 c = 1;
    uint128 b = 1;


    // To cut uint to uint8 costs more gas
    uint8 demo2 = 1;

    constructor(){

    }

    // temp variables consume additional gas
    // arrays more costly than mapping, dynamic arrays > static length arrays
    uint[] payments;
    function pay() external payable {
        //temp address var
        address _from = msg.sender;
        require(_from != address(0), "Zero address");
        payments.push(msg.value);
    } // total gas value 46567

    // BUT with arrays uint8 > uint because of data compression
    uint[] demoArray = [1,2,3];


    // Do not split function into smaller once's if possible
    uint calcVar = 5;
    uint d;
    function calc() public  {
        uint _a = 1+calcVar;
        uint _b = 2*calcVar;
        calc2(_a, _b);
    }

    function calc2(uint _a, uint _b) public  {
        d = _a + _b;
    }
}
