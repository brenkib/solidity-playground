// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IERC20.sol";

contract ERC is IERC20 {
    uint totalTokens;
    address owner;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;
    string private _name;
    string private _symbol;

    function name() external view returns(string memory) {
        return _name;
    }

    function symbol() external view returns(string memory) {
        return _symbol;
    }

    function decimals() external pure returns(uint) {
        return 18; // 1 token = 1 wei
    }

    function totalSupply() external view returns(uint) {
        return totalTokens;
    }

    modifier enoughTokens(address _from, uint _amount) {
        require(balances[_from] >= _amount, "Not enough tokens");
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Not allowed");
        _;
    }

    constructor(string memory name, string memory symbol, uint initialSupply, address shop){
        _name = name;
        _symbol = symbol;
        owner = msg.sender;
        // Give supply to shop
        mint(initialSupply, shop);
    }

    function mint(uint amount, address shop) public onlyOwner  {
        _beforeTokenTransfer(address(0), shop, amount);
        balances[shop] += amount;
        totalTokens += amount;
        emit Transfer(address(0), shop, amount);
    }

    function _burn(address account, uint value) internal onlyOwner {
        _beforeTokenTransfer(account, address(0), value);
        balances[account] -= value;
        totalTokens -= value;
    }

    function balanceOf(address account) external view returns(uint) {
        return balances[account];
    }

    function transfer(address to, uint amount) external enoughTokens(msg.sender, amount){
      _transfer(msg.sender, to, amount);
    }

    function _transfer(address from, address to, uint value) internal {
        _beforeTokenTransfer(msg.sender, to, value);
        balances[msg.sender] -= value;
        balances[to] += value;

        emit Transfer(msg.sender, to, value);
    }

    function allowance(address _owner, address _spender) public view returns(uint) {
        return allowances[_owner][_spender];
    }

    function approve(address spender, uint amount) public {
       _approve(msg.sender, spender, amount);

    }

    function _approve(address sender, address spender, uint amount) internal virtual {
        allowances[msg.sender][spender] = amount;
        emit Approve(sender, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint amount) public enoughTokens(sender, amount) {
        _beforeTokenTransfer(sender, recipient, amount);
        allowances[sender][recipient] -= amount; // error if < 0

        _transfer(sender, recipient, amount);

    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint amount
    ) internal virtual {}

}
