// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract XIRTAM_Staking is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public stakingToken;
    uint256 public constant APY = 18;
    uint256 private constant SECONDS_IN_A_YEAR = 365 * 24 * 3600;
    uint256 private constant WITHDRAWAL_FEE = 25; // 2.5% fee
    uint256 private constant FEE_DENOMINATOR = 1000;

    struct Stake {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Stake) private stakes;

    constructor() {
        stakingToken = IERC20(0xe73394F6a157A0Fa656Da2b73BbEDA85c38dfDeC);
    }

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Staking amount should be greater than 0");

        // Update the stake
        Stake storage userStake = stakes[msg.sender];
        userStake.amount = userStake.amount + amount;
        userStake.timestamp = block.timestamp;

        // Transfer the tokens
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Unstaking amount should be greater than 0");

        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount >= amount, "Not enough staked tokens");

        // Update the stake
        userStake.amount = userStake.amount - amount;
        userStake.timestamp = block.timestamp;

        // Calculate the withdrawal fee
        uint256 fee = (amount * WITHDRAWAL_FEE) / FEE_DENOMINATOR;

        // Transfer the tokens
        stakingToken.safeTransfer(msg.sender, amount - fee);
    }

    function compound() external nonReentrant {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No staked tokens");

        uint256 reward = calculateReward(msg.sender);
        userStake.amount = userStake.amount + reward;
        userStake.timestamp = block.timestamp;
    }

    function withdrawReward() external nonReentrant {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No reward to withdraw");

        Stake storage userStake = stakes[msg.sender];
        userStake.timestamp = block.timestamp;

        // Transfer the reward
        stakingToken.safeTransfer(msg.sender, reward);
    }

    function calculateReward(address user) public view returns (uint256) {
        Stake storage userStake = stakes[user];

        if (userStake.amount == 0) {
            return 0;
        }

        uint256 stakingDuration = block.timestamp - userStake.timestamp;
        uint256 reward = (userStake.amount * stakingDuration * APY) / (SECONDS_IN_A_YEAR * 100);

        return reward;
    }

        function getUserStake(address user) external view returns (uint256) {
        return stakes[user].amount;
    }

    function getStakingDuration(address user) external view returns (uint256) {
        return block.timestamp - stakes[user].timestamp;
    }

    function getReward(address user) external view returns (uint256) {
        return calculateReward(user);
    }

    function getUnstakeFee(uint256 amount) public pure returns (uint256) {
        return (amount * WITHDRAWAL_FEE) / FEE_DENOMINATOR;
    }

    function rescueTokens(address token, uint256 amount) external onlyOwner {
        require(token != address(stakingToken), "Cannot withdraw staking tokens");
        IERC20(token).safeTransfer(msg.sender, amount);
    }

    function rescueETH(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient ETH balance in the contract");
        payable(msg.sender).transfer(amount);
    }

}
