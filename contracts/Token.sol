// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC165.sol";
import "./library/Ownership.sol";

interface IERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
}

contract Token is IERC20, IERC165, Ownership {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    
    mapping(address=>uint256) private balances;
    mapping(address=>mapping(address=>uint256)) private allowances;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) Ownership(msg.sender){
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function balanceOf(address _owner) public view returns(uint256){
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns(uint256){
        return allowances[_owner][_spender];
    }

    function supportsInterface(bytes4 interfaceID) public pure returns(bool){
        return (
            interfaceID == this.name.selector
                        ^ this.symbol.selector
                        ^ this.decimals.selector
                        ^ this.totalSupply.selector
                        ^ this.balanceOf.selector
                        ^ this.transfer.selector
                        ^ this.transferFrom.selector
                        ^ this.approve.selector
                        ^ this.allowance.selector
        );
    }

    function transfer(address _to, uint256 _value) public returns(bool){
        require( balances[msg.sender] >= _value , "ERC20: Not enough balance" );
        bool success = _transfer(msg.sender, _to, _value);

        return success;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool){
        if(msg.sender == _from){
            require(balances[_from] >= _value, "ERC20: Not enough balance" );
        } else {
            require(allowances[_from][msg.sender] >= _value, "ERC20: Not enough allowance");
            allowances[_from][msg.sender] -= _value;
        }

        bool success = _transfer(_from, _to, _value);
        return success;
    }

    function approve(address _spender, uint256 _value) public returns(bool){
        require(balances[msg.sender] >= _value, "ERC20: Not enough balance");
        
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) public returns(bool){
        require( _from != address(0), "ERC20: Invalid giver");
        require( _to != address(0) , "ERC20: Invalid receiver" );

        balances[_from] -= _value;
        balances[_to] += _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function mint(address _to, uint _value) public onlyOwner(msg.sender) returns(bool){
        totalSupply += _value;
        balances[_to] += _value;
        emit Transfer(owner, _to, _value);
    }
}