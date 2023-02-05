// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13 <= 0.8.19;

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
    uint numOfConfirmation; // num of approvals
  }

  Transaction[] public transaction;  // queue of transactions in an array of txs

  // METHODS
  /// @notice submit a transaction that can be executed if at least 2 other signers approve.
  /// @dev this is the constructor method
  /// @param _owners number of multisign wallet owners
  /// @param _numConfirmationsRequired number of signers needed for approval
  constructor(address[] memory _owners, uint _numConfirmationsRequired) public {
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


  /// @notice submit a transaction that can be executed if at least 2 other signers approve.
  /// @dev Still WIP
  function submitTransaction() public {}

  /// @notice other others can approve transaction by calling this function.
  /// @dev Still WIP
  function confirmTransaction() public {}

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