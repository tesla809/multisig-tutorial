// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract MultiSigWallet {
  // EVENTS
  event Deposit(address indexed sender, uint amount);
  event Submit(
    address indexed owner,
    uint indexed txIndex,
    address indexed to,
    uint value,
    bytes data); // emit when tx is submitted and waiting for other owners to approve
  event Approve(address indexed owner, uint indexed txId); // emit when approved
  event Revoke(address indexed owner, uint indexed txId); // emit if changed mind, revoke
  event Execute(address indexed owner, uint indexed txId);  // emit once sufficient amount of approvals


  // STATE VARIABLES 
  struct Transaction {
    address to;  // where tx is executed
    uint value;  // amount of ether (in wei) sent to the 'to' address
    bytes data;  // data to be sent to the 'to' address
    bool executed; // once executed, tx set to true
    uint numOfConfirmations; // total number of confirmations a tx has
  }
  Transaction[] public transactions; //  array of transactions

  address[] public owners; // array of all owners
  mapping(address => bool) public isOwner; // false by default. If true, then owner
  uint public numOfRequiredApprovals; // number of approvals required before tx can be executed


  // if txapproval >= numOfRequiredApprovals -> execute tx 
  // store approval of each tx, by each owner
  // txIndex => (owner address => tx approved by owner or not)
  mapping(uint => mapping(address => bool)) public isApproved;

  // MODIFIERS
  modifier onlyOwner(address _to) {
    require(isOwner[msg.sender], "invalid owner: not owner"); // use mapping to be gas efficient, instead of looping over array of owners
    _;
  }

  modifier txExist(uint _txId) {
    // exists if transaction index < than size of array. since if not, won't be as long
    // will always be 1 less than, since array starts at zero
    require(_txId < transactions.length, "invalid tx: transaction does not exist");
    _; // if exists execute the rest of the code
  }

  modifier notApproved(uint _txId) {
    // check if caller has already approved function
    require(!isApproved[_txId][msg.sender], "invalid tx: transaction already approved by address");
    _;
  }

  modifier notExecuted(uint _txId) {
    // run only if false. If true, tx already executed
    require(!transactions[_txId].executed, "invalid tx: transaction has already been executed");
    _;
  }

  // CONSTRUCTOR
  constructor(address[] memory _owners, uint _numOfRequiredApprovals) {
    require(_owners.length > 0, "invalid: owners required"); // needs owners
    require(
      _numOfRequiredApprovals > 0 && _numOfRequiredApprovals <= _owners.length, 
      "invalid: required approvals must be greater than 0 and less than number of owners"
    ); // needs approvals and number needs to be less than total owners to work

    for(uint i = 0; i < _owners.length; i++) {
      address owner = _owners[i];
      require(owner != address(0), "invalid owner: submitted burner address"); // no one controls burner address
      require(!isOwner[owner], "invalid owner: duplicate address"); // require owner is unique non duplicate
    
      isOwner[owner] = true; // flip to true to prevent duplicates
      owners.push(owner); // add owner to owners array 
    }
    numOfRequiredApprovals = _numOfRequiredApprovals;
  }

  // HELPER METHODS
  // private helper method to get total number of approvals from a tx
  // needed for submission
  // count initialized in function signature to save gas
  function _getApprovalCount(uint _txId) private view returns (uint count) {
    // for each owner, check if approved is true
    // if true, increment the count
    for(uint i = 0; i < owners.length; i++) {
      // current owner in isApproved array
      if(isApproved[_txId][owners[i]]) {
        count += 1;
      }
    }
    return count; // explictly return count for clarity. Implictly returned by defining in function signature 
  }

  // returns array of owners
  function getOwners() public view returns (address[] memory) {
    return owners;
  }

  function getTransactionCount() public view returns (uint) {
    return transactions.length;
  }

  function getTransaction(uint _txIndex) 
    public 
    view 
    returns (
      address to,
      uint value,
      bytes memory data,
      bool executed,
      uint numConfirmationsRequired
    ) {
      // access storage to return
      Transaction storage transaction = transactions[_txIndex];

      return (
        transaction.to,
        transaction.value,
        transaction.data,
        transaction.executed,
        transaction.numOfConfirmations
      );
  }

  // METHODS
  // enable wallet to recieve ether with fallback functions
  receive() external payable {
    emit Deposit(msg.sender, msg.value); // msg.sender -> caller, msg.value -> funds passed
  }

  // only owners can submit a tx
  // once tx submitted, and has enough approvals, then any owner can execute tx
  // calldata: used b/c function is external and cheaper on gas than memory
  function submit(address _to, uint _value, bytes calldata _data) 
    external 
    onlyOwner {
      // since new,  the latest value - 1, since all arrays are zero indexed aka start counting at 0
      uint txId = transaction.length

      // push all arguments into a Transaction struct and add to transactions array
      transctions.push(Transaction({
        to: _to, 
        value: _value, 
        data: _data, 
        executed: true
        numOfConfirmations: 0 // confirmations are 0 when created
      }));

      emit Submit(msg.sender, txId, _to, _value, _data); 
  }

  // once tx are submitted, other owners can approve it.
  // tx should exist, not be approved yet and not executed.
  function approve(uint _txId) 
    external 
    onlyOwner
    txExist(_txId)
    notApproved(_txId)
    notExecuted(_txId) {
      // get storage to manipulate state variable
      Transaction storage transaction = transactions[_txIndex];
      transaction.numOfConfirmations += 1; // increment confirmation total
      // set transaction to approved
      isApproved[_txId][msg.sender] = true;
      emit Approve(msg.sender, _txId);
  }

  function execute(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
    // store data in Transaction struct and update it
    // persist manipulations in storage 
    Transaction storage transaction = transactions[_txId];

    // check if confirmations meets approval count 
    require(
      transaction.numOfConfirmations >= numConfirmationsRequired, 
      "invalid transaction: not enough confirmations to approve"
    );

    transaction.executed = true; // set to executed

    // .to - low level address to execute transaction
    // .call - calls contract or address
    // .value - has amount of ether to send to address is in
    // .data - the information for the contract if applicable
    // returns two outputs, but only need success return value
    (bool success, )  = transaction.to.call{value: transaction.value}(
      transaction.data
    );

    // check if transaction is successful
    require(success, "invalid: transaction successful");

    emit Execute(msg.sender, _txId); // let front end know of tx execution
  }

  // before tx is executed, owner wants to undo approval
  function revoke(uint _txId) 
    external 
    onlyOwner 
    txExist(_txId)
    notExecuted(_txId) {
      // check that tx is approved already 
      require(isApproved[_txId][msg.sender], "invalid: transaction is not approved");
      
      // manipulate state variable
      Transaction storage transaction = transactions[_txIndex];

      transaction.numOfConfirmations -= 1; // remove confirmation
      isApproved[_txId][msg.sender] = false; // set to false
      emit Revoke(msg.sender, _txId); // let front end know
  }

}

/*
Great application to build with intermediate skill

*/

