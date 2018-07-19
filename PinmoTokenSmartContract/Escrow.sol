pragma solidity ^0.4.24;

/**
 * Escrow function to hold tokens after reviewing the transactions
 */ 
contract Escrow
{
    uint balance;
    address public buyer;
    address public seller;
    address private escrow;
    uint private start;
    bool buyerOk;
    bool sellerOk;
    
    /**
    * constructor that contains the buyer and seller addresses
    */ 
    constructor (address buyer_address, address seller_address) 
        public
    {
        buyer = buyer_address;
        seller = seller_address;
        escrow = msg.sender;
        start = now;
    }

    /**
    * Function to accept the payment
    */ 
    function accept() 
        payable 
        public
    {
        if (msg.sender == buyer) buyerOk = true;
        else if (msg.sender == seller) sellerOk = true;
        if (buyerOk && sellerOk) payBalance();

        // Freeze 30 days before release to buyer. The customer needs to remember
        // to call this method after freeze period.
        else if (buyerOk && sellerOk && now > start + 30 days) selfdestruct(buyer);
    }

    /**
     * Function to pay the held balance if it hasn't been paid
     */ 
    function payBalance() 
        private
    {
        escrow.transfer(address(this).balance / 100);
        if (seller.send(address(this).balance)) balance = 0;
        else revert();
    }

    /**
     * Function to deposit the balance of the transaction
     */ 
    function deposit() 
        public 
        payable 
    {
        if (msg.sender == buyer) balance += msg.value;
    }

    /**
    * Function to cancel the balance that was held
    */ 
    function cancel() 
        public
    {
        if (msg.sender == buyer) buyerOk = false;
        else if (msg.sender == seller) sellerOk = false;
        if (!buyerOk || !sellerOk) selfdestruct(buyer);
    }

    /**
     * Function to kill the escrow function on this transaction
     */ 
    function kill() public payable {
        if (msg.sender == escrow) selfdestruct(buyer);
    }
}