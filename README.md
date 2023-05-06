# Staking Contract

A Solidity smart contract for staking ERC20 tokens. The contract allows users to stake tokens, unstake tokens, withdraw rewards, and compound rewards. The contract also includes a fee on unstaking tokens and provides utility functions for the contract owner.

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
