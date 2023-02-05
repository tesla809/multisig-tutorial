// SPDX-License-Identifier: MIT
// pragma solidity >=0.8.10;
pragma solidity ^0.5.11; // write first in 0.5 to keep close to tutorial, then update to >=0.8.13 <= 0.8.19;


// NOTE: original tutorial written in solidity version 0.5
// Somethings need to be double checked and optimized for 0.8.13 and above

/// @title Sample smart contract based multisignature Wallet
/// @author Anthony Albertorio
/// @notice Do not use in production. For learning purposes only.
/// @dev Code is not audited.
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

  Transaction[] public transactions;  // queue of transactions in an array of txs

  // CONSTRUCTOR
  // NOTE: check if public is needed on contract.
  /// @notice submit a transaction that can be executed if at least 2 other signers approve.
  /// @dev this is the constructor method
  /// @param _owners number of multisign wallet owners
  /// @param _numConfirmationsRequired number of signers needed for approval
  constructor(address[] memory _owners, uint _numConfirmationsRequired) public {
        require(_owners.length > 0, "owners required"); // needs owners
        require(
          _numConfirmationsRequired > 0 &&
          _numConfirmationsRequired <= _owners.length,
          "invalid number of required confirmations"
        ); // 0 < approval <= owners - confirmations more than 0 and less than or equal to number of owners
  
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

  recieve() external payable {
    emit Deposit(msg.sender, msg.value, address(this).balance);
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
    require(_txIndex < transactions.length, "tx does not exist");
    _;
  }

  // confirm transaction is not executed yet
  modifier notExecuted(uint _txIndex) {
    // Throw if true. Passes if false, since inverse due to `!`
    require(!transactions[_txIndex].executed, "already executed");
    _;
  }

  // TO DO: FIX Modifier for 0.8.17 and up
  // check transaction has not been confirmed
  // owner can only confirm transction once
  modifier notConfirmed(uint _txIndex) {
    // check address and see if confirmed
    require(transactions[_txIndex].isConfirmed[msg.sender], "tx already confirmed");
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
    uint txIndex = transactions.length; // get id for transaction we will create

    // add Transaction struct to transaction[] array
    transactions.push(Transaction({
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
      // get transaction and place in storage
      // describe this further in README.md
      Transaction storage transaction = transactions[_txIndex];
      transaction.isConfirmed[msg.sender] = true; // set to isConfirm true. Means that msg.sender aka wallet owner has approved tx.
      transaction.numConfirmations += 1;  // increase number of confirmations by 1. Bounded by number of wallet owners. See constructor and state variables      

      emit ConfirmTransaction(msg.sender, _txIndex);
  }

  /// @notice once enough owners approve transaction, they will be able to execute the transaction
  /// @dev Can only call this function if approval threshold has been reached
  /// @param _txIndex id of transaction that is going to be called
  function executeTransaction(uint _txIndex) 
    public 
    onlyOwner 
    txExists(_txIndex) 
    notExecuted(_txIndex) {
      // get the Transaction struct
      Transaction storage transaction = transactions[_txIndex];
      // check if threshold to execute tx has been reached or passed
      require(
        transaction.numConfirmations >= numConfirmationsRequired, 
        "cannot execute tx"
      );
      // if enough confirmations
      transaction.executed = true;

      // execute the transaction with CALL
      (bool success, ) = transaction.to.call.value(transaction.value)(transaction.data); 
      require(success, "tx failed");
      
      // emit event with function caller and transaction index executed
      emit ExecuteTransaction(msg.sender, _txIndex);
  }

  /// @notice allows owner to cancel the confirmation
  /// @dev Still WIP
  function revokeConfirmation(
      uint _txIndex
  ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
      // get transaction from storage
      Transaction storage transaction = transactions[_txIndex];

      // check if transaction from caller has not been confirmed
      require(transaction.isConfirmed[msg.sender], "tx not confirmed");

      transaction.numConfirmations -= 1;
      transaction.isConfirmed[msg.sender] = false;

      emit RevokeConfirmation(msg.sender, _txIndex);
  }

  // fallback function declared as payable to send ether to contract
  function() payable external {
    emit Deposit(msg.sender, msg.value, address(this).balance);
  }


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