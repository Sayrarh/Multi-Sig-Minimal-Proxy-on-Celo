// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MultisigWallet {
    event Deposit(address indexed sender, uint256 amount, uint256 contractBal);
    event TransactionRequested(
        address indexed owner,
        uint256 indexed txnID,
        address indexed to,
        uint256 amount
    );
    event TransactionApproved(address indexed owner, uint256 indexed txnID);

    uint8 public constant MAX_OWNERS = 20; // Maximum number of owners allowed
    uint8 numofApprovalsRequired; // Number of approvals required for a transaction
    address public factory; // Address of the contract creator
    bool initialState; // Initial state of the contract
    address[] validOwners; // Array containing valid owners' addresses

    struct Transaction {
        address recipient; // Recipient of the transaction
        uint8 numOfConformations; // Number of confirmations received for the transaction
        bool approved; // Flag indicating if the transaction is approved
        uint80 amountRequested; // Amount requested in the transaction
    }

    Transaction[] allTransactions; // Array containing all transactions
    uint256[] successfulTxnIDs; // Array containing IDs of successful transactions

    uint256 txnID = 1; // ID of the next transaction

    //mapping to keep track of all transactions
    mapping(uint256 => Transaction) _transactions;
    //mapping to check if an owner as approved a transaction
    mapping(uint256 => mapping(address => bool)) public hasApprovedtxn;
    //mapping to check if an address is part of the owners
    mapping(address => bool) isOwner;

    /**
     * @dev Initializes the multisig wallet contract with owners and quorum.
     * @param _owners Array of addresses representing the owners of the wallet.
     * @param _quorum Number of approvals required for a transaction.
     */
    function initialize(address[] memory _owners, uint8 _quorum) external {
        require(initialState == false, "Contract Already Initialized");
        require(_quorum <= _owners.length, "Out of Bound!");

        require(_owners.length <= MAX_OWNERS, "Invalid owners");
        for (uint i; i < _owners.length; i++) {
            address owner = _owners[i];
            notAddressZero(owner);
            isOwner[owner] = true;
        }

        validOwners = _owners;
        numofApprovalsRequired = _quorum;
        factory = msg.sender;
        initialState = true;
    }

    /**
     * @dev Requests a transaction to be approved by the owners.
     * @param _to Address of the recipient of the transaction.
     * @param _amount Amount to be transferred in the transaction.
     * @return The ID of the requested transaction.
     */
    function requestTransaction(
        address _to,
        uint80 _amount
    ) external returns (uint256) {
        isAnOwner(msg.sender);
        notAddressZero(_to);
        require(_amount > 0, "Amt should be greater than zero");
        Transaction storage txn = _transactions[txnID];
        txn.recipient = _to;
        txn.amountRequested = _amount;
        uint256 currentTxnID = txnID;
        allTransactions.push(txn);

        txnID = txnID + 1;

        emit TransactionRequested(msg.sender, currentTxnID, _to, _amount);
        return currentTxnID;
    }

    /**
     * @dev Approves a transaction by an owner.
     * @param _ID The ID of the transaction to be approved.
     */
    function approveTransaction(uint256 _ID) external {
        isAnOwner(msg.sender);

        require(hasApprovedtxn[_ID][msg.sender] == false, "Already Approved");
        require(_ID > 0 && _ID < txnID, "InvalidID");

        Transaction storage txn = _transactions[_ID];
        require(txn.approved == false, "Txn has been completed");
        txn.numOfConformations = txn.numOfConformations + 1;
        hasApprovedtxn[_ID][msg.sender] = true;

        address beneficiary = txn.recipient;
        uint256 amount = txn.amountRequested;

        if (txn.numOfConformations >= numofApprovalsRequired) {
            txn.approved = true;
            (bool success, ) = payable(beneficiary).call{value: amount}("");
            require(success, "txn failed");
            successfulTxnIDs.push(_ID);
        }

        emit TransactionApproved(msg.sender, _ID);
    }

    /**
     * @dev Returns the total number of transactions.
     * @return The count of all transactions.
     */
    function getTxnsCount() external view returns (uint256) {
        return allTransactions.length;
    }

    /**
     * @dev Checks if the address is one of the valid owners.
     * @param user The address to be checked.
     */
    function isAnOwner(address user) private view {
        require(isOwner[user], "Not a valid owner");
    }

    /**
     * @dev Checks if the address is not a zero address.
     * @param user The address to be checked.
     */
    function notAddressZero(address user) private pure {
        require(user != address(0), "Invalid Address");
    }

    /**
     * @dev Returns an array of all valid owners' addresses.
     * @return Array of addresses representing the valid owners.
     */
    function getAllowners() external view returns (address[] memory) {
        return validOwners;
    }

    /**
     * @dev Returns the details of a specific transaction.
     * @param _ID The ID of the transaction.
     * @return The details of the transaction.
     */
    function getTxnDetails(
        uint256 _ID
    ) external view returns (Transaction memory) {
        Transaction storage txn = _transactions[_ID];
        return txn;
    }

    /**
     * @dev Returns an array of all transactions.
     * @return Array of all transactions.
     */
    function getAlltxnsInfo() external view returns (Transaction[] memory) {
        return allTransactions;
    }

    /**
     * @dev Returns an array of successful transaction IDs.
     * @return Array of successful transaction IDs.
     */
    function allSuccessfulTxnIDs() external view returns (uint256[] memory) {
        return successfulTxnIDs;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }
}
