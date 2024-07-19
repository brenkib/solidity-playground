// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ERC20/IERC20.sol";

contract ERC20 is IERC20 {
    uint totalTokens;
    address owner;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowances;
    string private _name;
    string private _symbol;

    function name() external view returns(string memory) {
        return _name;
    }

    function symbol() external view returns(string memory) {
        return _symbol;
    }

    function decimals() external pure returns(uint) {
        return 18; // 1 token = 1 wei   0.01 10^decimals,
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
        if(msg.sender == owner) {
            revert CustomError();
        }
        _;
    }

    error CustomError();

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
        _beforeTokenTransfer(from, to, value);
        balances[from] -= value;
        balances[to] += value;

        console.log(
            "Transferring from %s to %s %s tokens",
            from,
            to,
            value
        );
        emit Transfer(from, to, value);
    }

    function allowance(address _owner, address _spender) public view returns(uint) {
        return allowances[_owner][_spender];
    }

    function approve(address spender, uint amount) public {
        allowances[msg.sender][spender] = amount;
        emit Approve(msg.sender, spender, amount);

    }

    function transferFrom(address sender, address recipient, uint256 amount) public enoughTokens(sender, amount) {
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


contract BRToken is ERC20 {
    constructor(address shop) ERC20("BRToken", "BR", 20, shop) {}
}


import "hardhat/console.sol";
/* ERC20 Token shop/distributor/seller */
contract BRShop {
    IERC20 public token;
    address payable public owner;
    event Bought(uint _amount, address indexed _buyer);
    event Sold(uint _amount, address indexed _seller);

    constructor() {
        token = new BRToken(address(this));
        owner = payable(msg.sender);
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Not allowed");
        _;
    }

    function sell(uint _amount) external {
        require(_amount > 0 && token.balanceOf(msg.sender) > _amount, "Incorrect amount");
        uint allowance = token.allowance(msg.sender, address(this));

        require(allowance >= _amount, "Incorrect allowance");

        token.transferFrom(msg.sender, address(this), _amount);

        // pay to sender
        payable(msg.sender).transfer(_amount);

        emit Sold(_amount, msg.sender);
    }

    function tokenBalance() public view returns(uint) {
        return token.balanceOf(address(this));
    }

    receive() external payable {
        uint tokensToBuy = msg.value;
        require(tokensToBuy > 0, "Not enough funds");
        require(tokenBalance() >= tokensToBuy, "Not enough tokens");

        token.transfer(msg.sender, tokensToBuy);
        emit Bought(tokensToBuy, msg.sender);
    }
}