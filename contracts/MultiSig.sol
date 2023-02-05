// SPDX-License-Identifier: MIT
// pragma solidity >=0.8.13 <= 0.8.19;
pragma solidity ^0.5.11; // write first in 0.5 to keep close to tutorial, then update to >=0.8.13 <= 0.8.19;


// NOTE: original tutorial written in solidity version 0.5
// Somethings need to be double checked and optimized for 0.8.13 and above

/// @title Sample smart contract based multisignature Wallet
/// @author Anthony Albertorio
/// @notice Do not use in production. For learning purposes only.
/// @dev Code is not audited.
/// @custom:experimental This is an experimental contract.
contract MultiSigWallet {
  // EVENTS
  // emitted when ether is sent to this contract 
  event Deposit(address indexed sender, uint amount, uint balance);
  event SubmitTransaction(
    address indexed owner,
    uint indexed txIndex,
    address indexed to,
    uint value,
    bytes data
  );
  event ConfirmTransaction(address indexed owner, uint indexed txIndex);
  event RevokeConfirmation(address indexed owner, uint indexed txIndex);
  event ExecuteTransaction(address indexed owner, uint indexed txIndex);

  // STATE VARIABLES
  address[] public owners; // number of owners
  mapping(address => bool) public isOwner; // to see if address is owner or not, check for duplicate addresses
  uint public numConfirmationsRequired; // minumum threshold for approval
  
  // when tx is proposed, we create this struct and store in transaction array
  struct Transaction {
    address to;  // where to send tx
    uint value;  // amount of ether to send to address
    bytes data;  // if calling a contract, store tx data to be sent to it. 
    bool executed; // store if tx executed or not
    mapping(address => bool) isConfirmed; // when owner approves tx, store in address(owner address?) and bool (if approve)
    uint numConfirmations; // num of approvals
  }

  Transaction[] public transaction;  // queue of transactions in an array of txs

  // CONSTRUCTOR
  // NOTE: check if public is needed on contract.
  /// @notice submit a transaction that can be executed if at least 2 other signers approve.
  /// @dev this is the constructor method
  /// @param _owners number of multisign wallet owners
  /// @param _numConfirmationsRequired number of signers needed for approval
  constructor(address[] memory _owners, uint _numConfirmationsRequired) {
    require(_owners.length > 0, "owners required"); // needs owners
    require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= owners.length); // 0 < approval <= owners - confirmations more than 0 and less than or equal to number of owners
  
    // TO FIX. Looping is not good usually 
    // copy owners from input to state variables
    for (uint i = 0; i < _owners.length; i++) {
      address owner = _owners[i];

      require(owner != address(0), "invalid owner"); // owner can't be 0x000.. burn account
      require(isOwner[owner], "owner not unique"); // check if duplicate address

      isOwner[owner] = true; // check if address is already an owner. If not, set to true 
      owners.push(owner); // add owner to owners state variable
    }
    numConfirmationsRequired = _numConfirmationsRequired;
  }

  // MODIFIERS
  // Note: some of these will be replaced by OpenZeppelin libraries
  modifier onlyOwner() {
    require(isOwner[msg.sender], "not owner"); // look at mapping isOwner and check if caller's address is there
    _; // if owner, execute the rest of the function
  }

  // confirm transaction exists
  modifier txExists(uint _txIndex) {
    // if tx longer than length, then doesn't exist
    require(transaction[_txIndex < transactions.length], "tx does not exist");
    _;
  }

  // confirm transaction is not executed yet
  modifier notExecuted(_txIndex) {
    // Throw if true. Passes if false, since inverse due to `!`
    require(!transaction[_txIndex].executed, "already executed")
    _;
  }

  // TO DO: FIX Modifier for 0.8.17 and up
  // check transaction has not been confirmed
  // owner can only confirm transction once
  modifier notConfirmed(_txIndex) {
    // check address and see if confirmed
    require(transaction[_txIndex].isConfirmed[msg.sender], "tx already confirmed");
    _;
  }

  // METHODS
  /// @notice submit a transaction that can be executed if at least 2 other signers approve.
  /// @dev Only one of the owners can call function 
  /// @dev Needs update to solidity 0.8.13 and up
  /// @param _to address transaction is going to
  /// @param _value amount of ether sent
  /// @param _data if calling smart contract, transaction data that is needed to be sent   
  function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner {
    uint txIndex = transaction.length; // get id for transaction we will create

    // add Transaction struct to transaction[] array
    transaction.push(Transaction({
      to: _to,
      value: _value,
      data: _data,
      executed: false,
      numConfirmations: 0
    }));

    // send event that transaction has been sent
    emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
  }

  /// @notice other others can approve transaction by calling this function.
  /// @dev Needs update to solidity 0.8.13 and up
  /// @param _txIndex id of transaction that is going to be confirmed
  function confirmTransaction(uint _txIndex) public 
    onlyOwner 
    txExists(_txIndex) 
    notExecuted(_txIndex) 
    notConfirmed(_txIndex) {
      // ... do something

  }

  /// @notice can call this function to execute transcaction if enough minumum number of signers is reached.
  /// @dev Still WIP
  function executeTransaction() public {}

  /// @notice allows owner to cancel the confirmation
  /// @dev Still WIP
  function revokeConfirmation() public {}

}


/*
Multi Sig Wallet 

event 
array 
mapping 
struct
constructor
error 
for loop
fallback and payable
call 
view function

Demo 
1. Send Ether to an account
2. Call another contract

Extend
1. More than 1 signer
2. Create configurable vault to lock and store assets
*/