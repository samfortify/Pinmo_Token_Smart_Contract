pragma solidity ^0.4.24;

/**
* ERC-20 standard token interface as defined at:
* <a href="https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md">here</a>.
*/
contract Token {
    
    /**
    * Function to get the total amount of tokens in circulation.
    * 
    * @return the total amount of tokens in circulation
    */
    function totalSupply () 
        public
        view 
        returns (uint256 supply);
        
    /**
    * Function to get the number of tokens currently belonging to a given 
    * owner.
    * 
    * @param _owner is the address on which the current tokens are going to be 
    * obtained.
    * 
    * @return the total number of tokens currently in the owner's address
    */
    function balanceOf (
        address _owner
        ) 
        public 
        view 
        returns (uint256 balance);
    
    /**
    * Obtain the total tokens that the spender is able to use for a transfer
    * 
    * @param _owner is the address on which the current tokens are going to be
    * transfer from.
    * 
    * @param _spender is the address on which the current tokens are going to
    * be transfer to.
    * 
    * @return the number of tokens given to the spender that are currently
    * allowed to transfer from a given owner
    */ 
    function allowance (
        address _owner, 
        address _spender
        )
        public 
        view 
        returns (uint256 remaining);
        
    /**
    * Approves the transaction of a given number of tokens from the sender
    * 
    * @param _spender address of the person transfering the tokens
    * 
    * @param _value the amount of tokens that are subject to the transfered
    * 
    * @return true if the token transfer was approved and false if not
    */ 
    function approve (
        address _owner,
        address _spender, 
        uint256 _value
        )
        public 
        returns (bool success)
    {
        emit Approval(_owner, _spender, _value);
        return true;
    }
        
    /**
    * Transfer a number of tokens from the sender address to the given recipient
    * 
    * @param _to address where the tokens are going to be transfered to
    * 
    * @param _value total number of tokens that are going to be transfered
    * 
    * @return true if the token transfer was successfull and false if it fails
    * 
    */ 
    function transfer (
        address _to, 
        uint256 _value
        )
        public 
        returns (bool success);
        
    /**
    * Transfer the given number of tokens from the owner to the recipient
    * 
    * @param _from the address where the tokens are taken from
    * 
    * @param _to the address where the tokens are going to be transfered to
    * 
    * @param _value total number of tokens that are going to be transfered
    * 
    * @return true if the token transfer was successfull and false if it fails
    */
    function transferFrom (
        address _from, 
        address _to, 
        uint256 _value
        )
        public 
        returns (bool success);
        
    /**
    * Event to log when tokens are transfer from one user to another
    * 
    * @param _from address of the original owner of the tokens
    * 
    * @param _to address of the new owner of the tokens
    * 
    * @param _value total amount of tokens that were transfered in this
    * transaction
    */  
    event Transfer (
        address indexed _from, 
        address indexed _to, 
        uint256 _value
    );
    
    /**
    * Event to log when the owner approved the transfer of the tokens to a
    * given owner
    * 
    * @param _owner address of the original owner of the tokens that got
    * trasnfered
    * 
    * @param _spender address of who was allowed to transfer the tokens that
    * belonged to the owner
    * 
    * @param _value number of tokens that were approved to be transfer by the
    * original owner
    *  
    */ 
    event Approval (
        address indexed _owner, 
        address indexed _spender, 
        uint256 _value
    );
}