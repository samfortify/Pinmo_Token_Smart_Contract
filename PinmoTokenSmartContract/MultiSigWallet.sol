pragma solidity ^0.4.24;

/**
* Multisignature wallet to approve transfers within wallets as a safe guard
* that multiple approvals are needed
*/ 

// this is safe to implement but it consumes gas 
contract MultiSigWallet 
{ 
    address private _owner;
    
    /**
    * mapping from addresses of token owners
    */ 
    mapping(address => uint8) private _owners; 
    
    /**
    * Constant value for minimum number of signatures
    * uint for the transaction id storage as private
    */ 
    uint constant MIN_SIGNATURES = 2; // number of signatures required 
    uint private _transactionsIdx;
    
    /**
    * the base structure for the transaction
    * @param _from address where the transfer is initiated
    * 
    * @param _to address where the tokens are going to be transfered to
    * 
    * @param _amount total number of tokens that are part of this transaction
    * 
    * @param _signatureCount total number of signatures provided by the owners
    * 
    * @param _signatures mapping that contains all the signatures of the
    * owners
    */ 
    struct Transaction
    {
        address _from;
        address _to;
        uint _amount;
        uint8 _signatureCount;
        mapping (address => uint8) _signatures;
    }
    
    /**
    * mapping of uint transactions that contains all the pending transactions
    * @param _transactions number of transactions in the queue
    * 
    * @param _pendingTransactions number of pending transactions in the
    * queue
    */ 
    mapping (uint => Transaction) private _transactions;
    uint[] private _pendingTransactions;
    
    /**
    * Modifier to verified the owners needs to be equal to the msg.sender
    */ 
    modifier isOwner()
    {
        require(msg.sender == _owner);
        _;
    }
    
    /**
    * Modifier to check the owner is a valid owner
    */ 
    modifier validOwner()
    {
        // TODO: require(msg.sender == _owner || (_owners[msg.sender] != address(0x0) && _owners[msg.sender] == 1));
        require(msg.sender == _owner || _owners[msg.sender] == 1);
        _;
    }
    
    /**
    * Event to log the deposit of DepositFunds
    * @param _from address where the funds are coming from
    * 
    * @param _amount number of tokens to deposit
    */ 
    event DepositFunds(
        address _from, 
        uint _amount
    );
    
    /**
    * Event to log when the transaction was created
    * @param _from address where the transaction originated
    * 
    * @param _to address where the transaction finalized
    * 
    * @param _amount of tokens that are subject of the transaction
    * 
    * @param _transactionId identification of the transaction
    */ 
    event TransactionCreated(
        address _from, 
        address _to, 
        uint _amount, 
        uint _transactionId
    );
    
    /**
    * Event to log when the transaction was completed
    * @param _from addtress where the transaction originated
    * 
    * @param _to address where the transaction finalized
    * 
    * @param _amount of tokens that are subject of the transaction
    * 
    * @param _transactionId identification of the transaction
    */ 
    event TransactionCompleted(
        address _from, 
        address _to, 
        uint _amount, 
        uint _transactionId
    );
    
    /**
    * Event to log who signed the transaction
    * 
    * @param _by address of the owner that signed and approved the transaction
    * 
    * @param _transactionId id of the transaction that was signed
    */ 
    event TransactionSigned(
        address _by, 
        uint _transactionId
    );

    /**
    * Constructor that validates the owner oppon contract creation
    */ 
    constructor() MultiSigWallet() // can only be tested in the real environment
        public
    {
        _owner = msg.sender;
    }
    
    /**
    * Function to add an owner to sign transactions
    * 
    * @param _owner address that is going to get authorized to sign 
    * transactions
    */ 
    function addOwner(
        address _newOwner
        )
        isOwner
        public
    {
        _owners[_newOwner] = 1;    
    }

    /**
    * Function to remove an owner to sign transactions
    * 
    * @param _owner address that is going to be unauthorized to sign
    * transactions
    */ 
    function removeOwner(
        address _previousOwner
        )
        isOwner
        public
    {
        _owners[_previousOwner] = 0;
    }

    /**
     * function to make the DepositFunds payable
     */ 
    function ()
        public
        payable
    {
        emit DepositFunds(msg.sender, msg.value);
    }

    /**
    * Function to withdraw money from the account
    * 
    * @param _amount total tokens that sender wants to be withdrawn
    */ 
    function withdraw(uint _amount)
        public
    {
        transferTo(msg.sender, _amount);
    }
    
    /**
    * Function to transfer to a valid owner
    * @param _to address where the tokens are going to go to
    * 
    * @param _amount total amount of tokens that are going to be transfered
    */ 
    function transferTo(
        address _to, 
        uint _amount
        )
        validOwner
        public
    {
        require(address(this).balance >= _amount);
        uint transactionId = _transactionsIdx++;
        Transaction memory transaction;
        transaction._from = msg.sender;
        transaction._to = _to;
        transaction._amount = _amount;
        transaction._signatureCount = 0;
        
        _transactions[transactionId] = transaction;
        _pendingTransactions.push(transactionId);
        
        emit TransactionCreated(msg.sender, _to, _amount, transactionId);
    }

    /**
    * Function to obtain the pending transactions that need to be signed
    */ 
    function getPendingTransactions()
        view
        validOwner
        public
        returns (uint[])
    {
        return _pendingTransactions;
    }
    
    /**
     * Function to sign the transactions that are either pending or current
     * 
     * @param _transactionId the id of the transaction to be signed
     */ 
    function signTransaction(
        uint _transactionId
        )
        validOwner
        public
    {
        Transaction storage transaction = _transactions[_transactionId];
        // Transaction must exist
        require(0x0 != transaction._from);
        // Creator cannot sign the transaction 
        require(msg.sender != transaction._from);
        // Cannot sign a transaction more than once
        require(transaction._signatures[msg.sender] != 1);
        
        transaction._signatures[msg.sender] = 1;
        transaction._signatureCount++;
        
        emit TransactionSigned(msg.sender, _transactionId);
        
        if(transaction._signatureCount >= MIN_SIGNATURES)
        {
            require(address(this).balance >= transaction._amount);
            transaction._to.transfer(transaction._amount);
            emit TransactionCompleted(transaction._from, transaction._to, transaction._amount, _transactionId);
            deleteTransaction(_transactionId);
        }
    }
        
    /**
    * Function to delete any pending transactions
    * 
    * @param _transactionId that needs to be deleted
    */ 
    function deleteTransaction(uint _transactionId)
        validOwner
        public
    {
        uint8 replace = 0;
        uint pendingTransactionIndex = 0;

        for (uint i = 0; i < _pendingTransactions.length; i++)
        {
            if (replace == 1) _pendingTransactions[i - 1] = _pendingTransactions[i];
            else if (_transactionId == _pendingTransactions[i])
            {
                replace = 1;
                pendingTransactionIndex = i;
            }
        }
        // Delete transaction
        delete _pendingTransactions[pendingTransactionIndex];
        // Fill the empty spot with last element
        _pendingTransactions[pendingTransactionIndex] = _pendingTransactions[_pendingTransactions.length - 1];
         // Delete last element
        _pendingTransactions.length--;

        delete _transactions[_transactionId];
    }
        
    /**
    * Function to obtain the balance of a given wallet
    * 
    * @return balance of a given address
    */ 
    function walletBalance()
        view
        public
        returns (uint)
    {
        return address(this).balance;
    }
}