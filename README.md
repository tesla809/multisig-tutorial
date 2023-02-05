# Multi Sig Wallet 

## Project Goal 

We will learn the basics of how to build a MultiSig Wallet. Through this process we will understand `Solidity`, usages of CALL, DELEGEGATECALL, and other methods. 

Note: that the original tutorial written in `Solidity 0.5`. Some code will need to be double checked and optimized for `0.8.13` and above. So, first we will write in `Solidity 0.5`, then update to `0.8.13 to 0.8.19` to understand major differences.

Later, we will learn about Account Abstraction, and learn about it an applied manner by extending our wallet's capabilities.

This is the first draft of this project borrowing heavily from online tutorials. Later we will examine code from popular projects like Gnosis Safe. Expect many errors and inaccuracies. If you find any issues or have suggestions, please open an `issue` or `pull request` on this repo. Any and all insights or suggestions are welecomed. 

This project is **not** production ready nor audited. 

This tutorial initially borrow's heavily from Smart Contract Programmer's [Build A MultiSig Video Series](https://www.youtube.com/watch?v=Dh7r6Ze-0Bs). If you like it, give his series a like and his youtube channel a follow.

## MultiSig Wallet Overview
A multisigniture wallet is a smart contract based wallet that has many owners.

To spend from this wallet, the spender will have to get approval from the other owners. 

The wallet is called "multisigniture" because in order to approve the transaction, there needs to be more than 1 digital signature.

The amount of owners and fraction of signatures needed for approval can change depending on the implementation. 

For example, there can be wallets with:
- 5 owners
- where 3/5 signatures are needed for approval.

Since the wallet is a smart contract based, its logic is configurable, allowing new wallet features to be introduced.

### MultiSig Wallet Example 

Imagine a multiSig wallet with:
- an account that has 1 Ether and 100 USDC.
- 3 owners: Alice, Bob, and Carol
- 2/3 signers for approval

Scenerio 1:
Alice wants to withdraw 50 USDC and Bob approves this: 2/3 owners approve. So, Alice can withdraw the 50 USDC.

Scenerio 2:
Alice wants to withdraw 50 USDC. Bob and Carol denies this: only 1/3 owners approve, which is under 2/3. So, Alice cannot withdraw the 50 USDC.

Wallet 2:
- an account that has 1 Ether and 100 USDC.
- 5 owners: Alice, Bob, Carol, Dave, Eve
- 3/5 signers for approval

This wallet instance would require 3/5 signers for a transaction approval.

In short, multisig wallets in short hand called:
number of approvers / total number of approvers.

For example:
A 2/3 multisig wallet: requires 2 out of 5 signers
A 3/5 multsig wallet: requires 3 out of 5 signers
A 5/5 multisig wallet: requires 5 out of 5 signers

The capbilities and possiblilites of multisig wallets are super charged with an additional feature increasingly found in leading zero knowledge proof based layer-2 rollups: account abstraction. 

### Account Abstraction
Account abstraction treat smart contract accounts on the same level of Externally Owned Accounts (EOA). Combined with low gas fees, account abstraction makes multisignature wallets fesible for any usecase. 

These two concepts allow accounts to be shaped to the needs of a business, versus businesses being shaped to the rigid limits of the EOA accounts. 

The key idea to understand is that **account abstraction allows organizations to create curated experience for their users**. Together with multi-sig wallet as a primitive, account abstraciton on layer-2s opens to door for amazing web2 UX/UI, while keeping web3 self custody.

Account Abstraction with multisig wallets allows for improvements in: 
- **Security** to increase safety and self custody for users
- **Onboarding** to attract users and simplify interactions, reduced number of steps, or clicks.
- **Retention** methods to to keep users

Examples of improvement in UX/UI via wallets are:
- multi-factor authentication via any medium: Gmail, Google Auth, etc.
- General abstraction for plug and play services: easily add fraud monitoring, KYC, or any arbitrary service. One of the signaturies is the plug and play service, like fraud monitoring, etc.
- Safe transactions training wheels: create safe and curated experience with limits on trading size, margin and assets, or certain types of transactions based on expertise.  
- Social recovery: friends, mechanisms for anons to provide service for social recovery, better visual design language for social recovery.
- Innovations on vaults for safe storage: Deadman switches, account vaults for short term assets to trade and long term assets to hold with different permissions. For example: for long term assets, add customizable default locks like 1-week minimum lock to prevent stealing.
- and more.

## Multisig Wallet Implementation Explained

We will create a 2/3 multisig wallet.

The follow methods will exist:
1. submitTransaction- Alice will submit a transaction that can be executed if at least 2 owners approve. 
2. confirmTransction - Bob or Carol approve the transaction.
3. executeTransaction - with the required number of signatures, any of the owners can execute the transaction.
4. revokeConfirmation - Any of the signers can change their mind and revoke a signature.

Since this is a smart contract based wallet, our smart contract can do more that just send Ether or tokens.

The wallet will be able to call other smart contracts from the multisig wallet.

This can work with the above methods:
1. sendTransaction - Alice calls external contract
2. confirmTransaction - Carol approves the call 
3. executeTransaction - any of the signers can execute transaction and interact with the contract via the jointly owned multi-sig by calling this function.

### Methods Siganture Overview

```
/// @title Sample smart contract based multisignature Wallet
/// @author Anthony Albertorio
/// @notice Do not use in production. For learning purposes only.
/// @dev Code is not audited.
/// @custom:experimental This is an experimental contract.
contract MultiSigWallet {
  // EVENTS
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

  // METHODS
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
```

### Description of Methods and Events




## MultiSig Wallet Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```
