// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Contract {
    address otherContract;

    constructor(address _oC) {
        otherContract = _oC;
    }

    function callReceive() external payable {
        // no error if call failed
        (bool success, ) = otherContract.call{value: msg.value}("");
        // so we need to check
        require(success, "Received Error");
    }

    event Response(string response);

    function callSetName(string calldata _name) external  {

        (bool success, bytes memory response) = otherContract.call(
            abi.encodeWithSignature("setName(string)", _name)
        //abi.encodeWithSelector(AnotherContract.setName.selector, _name);
        );

        require(success, "Received Error");
        emit Response(abi.decode(response, (string)));
    }
}


contract AnotherContract {
    string public name;
    mapping (address => uint) public balances;

    function setName(string calldata _name) external returns(string memory) {
        name = _name;
        return name;
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
    }
}