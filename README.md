# XIRTAM Staking Contract

A Solidity smart contract for staking ERC20 tokens (specifically XIRTAM). The contract allows users to stake tokens, unstake tokens, withdraw rewards, and compound rewards. The contract also includes a fee on unstaking tokens and provides utility functions for the contract owner.

## Overview

The staking contract is built using Solidity 0.8.19 and utilizes OpenZeppelin libraries. The contract allows users to stake tokens, unstake tokens, compound rewards, and withdraw rewards. The staking contract also implements a 2.5% fee on unstaking tokens.

## Functions

### stake(uint256 amount)

Allows users to stake a specified `amount` of tokens. The staking balance and timestamp are updated accordingly.

### unstake(uint256 amount)

Allows users to unstake a specified `amount` of tokens. The user's staking balance is updated, and a 2.5% unstaking fee is deducted from the amount before transferring tokens back to the user.

### compound()

Allows users to compound their rewards by adding the calculated reward to their staking balance. The user's staking timestamp is also updated.

### withdrawReward()

Allows users to withdraw their rewards without unstaking tokens. The user's staking timestamp is updated, and the reward is transferred to the user's wallet.

### calculateReward(address user) public view returns (uint256)

Calculates the current reward for a user based on their staked amount, staking duration, and the APY (Annual Percentage Yield).

### getUserStake(address user) external view returns (uint256)

Returns the staked amount for a specified `user`.

### getStakingDuration(address user) external view returns (uint256)

Returns the staking duration for a specified `user`, calculated as the difference between the current timestamp and the user's staking timestamp.

### getReward(address user) external view returns (uint256)

Returns the calculated reward for a specified `user`.

### getUnstakeFee(uint256 amount) public pure returns (uint256)

Calculates and returns the unstaking fee for a specified `amount`.

### rescueTokens(address token, uint256 amount) external onlyOwner

Allows the contract owner to rescue any stuck tokens (except the staking token) by transferring the specified `amount` of the specified `token` to the owner's wallet.

### rescueETH(uint256 amount) external onlyOwner

Allows the contract owner to rescue any stuck ETH by transferring the specified `amount` of ETH to the owner's wallet.

## ReentrancyGuard

ReentrancyGuard is a Solidity library that provides a simple and effective way to protect against reentrancy attacks in your smart contracts. Reentrancy attacks can occur when a malicious contract calls a function of your contract and the function, in turn, calls an external contract before updating its state. The attacker can then exploit this vulnerability to manipulate the state of your contract and potentially drain its funds.

This library prevents reentrancy attacks by implementing a mutex (lock) pattern that can be added to your functions, ensuring that they can only be called once during a single transaction.

### How it works

ReentrancyGuard uses a boolean state variable, `_notEntered`, as a mutex (lock) to protect functions from being called again before they finish executing. The variable is set to `true` by default, indicating that the function is not being executed. When a function protected by the ReentrancyGuard modifier is called, the mutex is set to `false`, which prevents the function from being called again until it has finished executing.

Here's a simple example of how ReentrancyGuard works:

```
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MyContract is ReentrancyGuard {
    uint256 public value;

    function updateValue(uint256 newValue) external nonReentrant {
        // Some logic that calls an external contract
        value = newValue;
    }
}
```

In this example, `updateValue` is protected by the `nonReentrant` modifier, which is provided by the `ReentrancyGuard` library. This ensures that the function can only be called once during a single transaction, preventing reentrancy attacks.

## When to use ReentrancyGuard

ReentrancyGuard should be used when your contract:

1. Calls an external contract, which could potentially be malicious or untrusted.
2. Updates its internal state after calling the external contract.

By protecting your functions with ReentrancyGuard, you can help ensure that your smart contracts are secure and resistant to reentrancy attacks.

## Limitations

While ReentrancyGuard is a valuable tool for preventing reentrancy attacks, it is not a comprehensive security solution. It is important to keep in mind that smart contract security is a complex topic, and you should follow best practices and perform thorough audits to ensure your contracts are secure.

Additionally, ReentrancyGuard should not be used to protect functions that rely on low-level calls (`call`, `delegatecall`, `staticcall`) since they bypass the `nonReentrant` modifier.
