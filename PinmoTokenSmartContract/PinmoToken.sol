pragma solidity ^0.4.24;

import "./AbstractToken.sol";

/**
* Pinmo Token Smart Contract
*/ 
contract PinmoToken is AbstractToken
{
    /**
    * Address of the owner of this smart contract
    */ 
    address private owner;
    
    /**
    * total number of tokens in circulation
    */ 
    uint256 tokenCount;
    
    /**
    * True if tokens are currently frozen for transfer or false if they are
    * not frozen
    */ 
    bool frozen = false;
    
    /**
    * Create a new Pinmo Token Smart Contract with the total amount of tokens
    * issued and a given msg.sender, as well, this makes the msg.sender the
    * owner of this smart contract
    * 
    * @param _tokenCount total number of tokens to be issued and given to the
    * msg.sender
    */ 
    constructor (
        uint256 _tokenCount
        ) 
        public
    {
        owner = msg.sender;
        _tokenCount = _tokenCount;
        accounts [msg.sender] = _tokenCount;
    }
    
    /**
    * Function to get the name of this token
    * 
    * @return the name of this token
    */ 
    function name () 
        public 
        pure 
        returns (string result)
    {
        return "Pinmo Token";
    }

    /**
    * Function to ge the symbol of this token
    * 
    * @return symbol for this token
    */ 
    function symbol () 
        public 
        pure 
        returns (string result)
    {
        return "PMT";
    }
    
    /**
    * Function to get the number of decimals
    * 
    * @return number of decimals for this token
    */ 
    function decimals () 
        public 
        pure 
        returns (uint8 result)
    {
        return 18;
    }

    /**
    * Function to get the total number of tokens in circulation
    * 
    * @return total number of tokens in circulation
    */ 
    function totalSupply () 
        public 
        view 
        returns (uint256 supply)
    {
        return tokenCount;
    }
    
    /**
    * Function to check if the transfer is frozen or not to
    * 
    * @param _to address where the tokens are going to
    * 
    * @param _value amount of tokens that were transfered.
    * 
    * @return true if the tokens are frozen and false if they are not
    */ 
    function transfer (
        address _to, 
        uint256 _value
        )
        public 
        returns (bool success)
    {
        if (frozen) return false;
        else return AbstractToken.transfer (_to, _value);
    }
    
    /**
    * Function to check if the transfer is frozen or not from
    * 
    * @param _from address where the tokens were transfered from
    * 
    * @param _to address where the tokens are going to
    * 
    * @param _value amount of tokens that were transfered
    * 
    * @return true if the tokens are frozen and false if they are not
    */ 
    function transferFrom (
        address _from, 
        address _to, 
        uint256 _value
        )
        public 
        returns (bool success)
    {
        if (frozen) return false;
        else return AbstractToken.transferFrom (_from, _to, _value);
    }
  
    /**
    * Function to check the allowance was approved
    * 
    * @param _spender address from the person that spends the tokens
    * 
    * @param _currentValue total value of the tokens before approving
    * 
    * @param _newValue total value of the tokens after approving
    * 
    * @return true if the msg.sender is equal to the current value and
    * false if there is a difference on this.
    */ 
    function approve (
        address _spender, 
        uint256 _currentValue, 
        uint256 _newValue
        )
        public 
        returns (bool success)
    {
        if (allowance (msg.sender, _spender) == _currentValue) // TODO: AbstractToken.allowance...
        return approve (_spender, _newValue); // TODO: AbstractToken.approve...
        else return false;
    }

    /**
    * Modifier to ensure the contract owner is making the call
    */ 
    modifier isOwner()
    {
        require(msg.sender == owner);
        _;
    }
    
    /**
    * Function to set a new owner of this contract
    * 
    * @param _newOwner address of the new owner approinted by the current owner
    */ 
    function setOwner (address _newOwner) 
        public
        isOwner
    {
        owner = _newOwner;
    }
  
    /**
    * Function to freeze all the transfers
    * May only be called by smart contract owner
    */ 
    function freezeTransfers () 
        public
        isOwner
    {
        if (!frozen)
        {
            frozen = true;
            emit Freeze ();
        }
    }

    /**
    * Unfreeze token transfers 
    * May only be calles by the Smart Contract owner
    */ 
    function unfreezeTransfers ()
        public
        isOwner
    {
        if (frozen)
        {
            frozen = false;
            emit Unfreeze ();
        }
    }
    
    /**
    * Logged when token transfers were frozen
    */ 
    event Freeze ();
    
    /**
    * Logged when token transfers were unfrozen
    */ 
    event Unfreeze ();
}