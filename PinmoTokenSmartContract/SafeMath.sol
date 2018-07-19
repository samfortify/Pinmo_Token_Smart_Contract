pragma solidity ^0.4.24;

/**
* ERC-20 standard token interface as defined at:
* <a href="https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md">here</a>.
*/

/**
* Math operations with safety checks that throw on error
*/ 
contract SafeMath
{
    uint256 constant private MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    
    /**
    * Function to add two uint246 values, throw in case of overflow.
    * 
    * @param x first value to be added
    * 
    * @param y second value to be added
    * 
    * @return the total amount of x + y
    */ 
    function addition (
        uint256 x, 
        uint256 y
        )
        pure 
        internal
        returns (uint256 z)
    {
        assert (x <= MAX_UINT256 - y); // TODO: (x + y <= MAX_UINT256)?
        return x + y;
    }
      
    /**
    * Function to substract two uint256 values, throw in case of overflow.
    * 
    * @param x first value to be substracted from
    * 
    * @param y second value to substract
    * 
    * @return the total amount of x - y
    */ 
    function substract (
        uint256 x, 
        uint256 y
        )
        pure 
        internal
        returns (uint256 z)
    {
        assert (x >= y);
        return x - y;
    }
      
    /**
    * Function to multiply two uint256 values, throw in case of overflow.
    * 
    * @param x first value to be multiplied
    * 
    * @param y second value to multiply by
    * 
    * @return the toal amoun of x by y
    */ 
    function multiply (
        uint256 x, 
        uint256 y
        )
        pure 
        internal
        returns (uint256 z)
    {
        if (y == 0) return 0; // Prevent division by zero at the next line
        assert (x <= MAX_UINT256 / y); // TODO: (x * y <= MAX_UINT256)?
        return x * y;
    }
}