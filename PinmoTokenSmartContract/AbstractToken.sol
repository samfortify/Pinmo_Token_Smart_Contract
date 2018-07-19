pragma solidity ^0.4.24;

import "./Token.sol";
import "./SafeMath.sol";

/**
* Abstract Token SmartContract that could be used as a base contract for 
* ERC-20 token contracts
*/ 
contract AbstractToken is Token, SafeMath 
{
    /**
    * Create a new Abstract Token Contract
    * Constructor that does nothing
    */ 
    constructor () public {}

    /**
    * Mapping from addresses of token holders to the numbers of tokens belonging 
    * to these token holders
    */ 
    mapping (address => uint256) internal accounts;
    
    /**
    * Mapping from addresses of token holders to the mapping of addresses of
    * spenders to the allowances set by these token holders to these spenders.
    */
    mapping (address => mapping (address => uint256)) internal allowances;
  
    /**
    * Function to know how many tokens a given spender is currently allowed 
    * to transfer from given owner
    * 
    * @param _owner address to get number of tokens allowed to be transferred 
    * from the owner of
    * 
    * @param _spender address to get number of tokens allowed to be transferred 
    * by the owner of
    * 
    * @return number of tokens given spender is currently allowed to transfer 
    * from given owner
    */ 
    function allowance (
        address _owner, 
        address _spender)
        
        public 
        view 
        returns (uint256 remaining)
    {
        return allowances [_owner][_spender];
    }

    /**
    * Function to get the number of tokens currently belonging to a given owner
    * 
    * @param _owner is the address on which the current tokens are going to 
    * be obtained.
    * 
    * @return number of tokens currently belonging to the owner of the 
    * address (owner)   
    */ 
    function balanceOf (
        address _owner
        ) 
        public 
        view 
        returns (uint256 balance)
    {
        return accounts [_owner];
    }
      
    /**
    * Function to allow the given spender to transfer a given amount of 
    * tokens from msg.sender
    * 
    * @param _spender address to allow the owner to transfer the amounnt 
    * of tokens given
    * 
    * @param _value number of tokens to allow to transfer
    * 
    * @return true if token transfer  was successfull or not
    */ 
    function approve (
        address _spender, 
        uint256 _value
        )
        public 
        returns (bool success) 
    {
        allowances [msg.sender][_spender] = _value;
        emit Approval (msg.sender, _spender, _value);
        return true;
    }
    
    /**
    * Function to transfer a given amount of tokens from message sender to 
    * a given recipient
    * 
    * @param _to address to transfer tokens to the owner of
    * 
    * @param _value amount of tokens that are going to be subject to this 
    * transaction
    * 
    * @return true if the tokens were trasnfered successfuly or 
    * false if it fail
    */ 
    function transfer (
        address _to, 
        uint256 _value
        )
        public 
        returns (bool success) 
    {
        uint256 fromBalance = accounts [msg.sender];
        uint256 toBalance = accounts [_to];

        if (fromBalance < _value) return false;
        if (_value > 0 && msg.sender != _to)
        {
            accounts [msg.sender] = substract (fromBalance, _value);
            accounts [_to] = addition (toBalance, _value);
        }
        emit Transfer (msg.sender, _to, _value);
        return true;
    }
  
    /**
    * Function to transfer given number of tokens from a given owner to a 
    * given recipient
    * 
    * @param _from address to transfer tokens from
    * 
    * @param _to address where the tokens are going to be transfered to
    * 
    * @param _value total number of tokens that are going to be subject  
    * to this transaction
    * 
    * @return true if the tokens were transfered scucessfuly or false if it failed
    */ 
    function transferFrom (
        address _from, 
        address _to, 
        uint256 _value
        )
        public 
        returns (bool success)
    {
        // Verify spender can spend that much currency
        uint256 spenderAllowance = allowances [_from][msg.sender];
        if (spenderAllowance < _value) return false;

        // Verify owner can spend that much currency
        uint256 fromBalance = accounts [_from];
        if (fromBalance < _value) return false;

        allowances [_from][msg.sender] = substract (spenderAllowance, _value); // TODO: Move to line 134, save gas?

        if (_value > 0 && _from != _to)
        {
            accounts [_from] = substract (fromBalance, _value);
            accounts [_to] = addition (accounts [_to], _value);
        }
        emit Transfer (_from, _to, _value);
        return true;
    }
}