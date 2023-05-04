// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.19;

interface ERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract XIRTAM_Staking {
    ERC20 public token;
    address public owner;
    uint256 public stakingStart;
    uint256 public stakingAPY = 18;
    uint256 public stakingDays = 365;
    uint256 public stakingEnd;
    uint256 public totalStaked;
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public stakingTime;
    mapping(address => uint256) public earnedBalance;

    constructor(address _token) {
        token = ERC20(_token);
        owner = msg.sender;
        stakingStart = block.timestamp;
        stakingEnd = stakingStart + stakingDays * 1 days;
    }

    function deposit(uint256 amount) external {
        require(token.balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(token.allowance(msg.sender, address(this)) >= amount, "Token allowance not set");
        require(stakingTime[msg.sender] == 0, "Already staked");

        token.transferFrom(msg.sender, address(this), amount);
        stakedBalance[msg.sender] = amount;
        stakingTime[msg.sender] = block.timestamp;
        totalStaked += amount;
    }

    function withdraw() external {
        require(stakingTime[msg.sender] > 0, "Not staked");
        require(block.timestamp >= stakingEnd, "Staking period not ended");

        uint256 staked = stakedBalance[msg.sender];
        uint256 earned = calculateEarnings(msg.sender);
        uint256 total = staked + earned;

        stakedBalance[msg.sender] = 0;
        stakingTime[msg.sender] = 0;
        earnedBalance[msg.sender] = 0;
        totalStaked -= staked;

        token.transfer(msg.sender, total);
    }

    function claim() external {
        require(stakingTime[msg.sender] > 0, "Not staked");
        require(block.timestamp >= stakingEnd, "Staking period not ended");

        uint256 earned = calculateEarnings(msg.sender);
        earnedBalance[msg.sender] = 0;

        token.transfer(msg.sender, earned);
    }

    function calculateEarnings(address staker) public view returns (uint256) {
        uint256 staked = stakedBalance[staker];
        uint256 timeStaked = block.timestamp - stakingTime[staker];
        uint256 stakingPeriod = stakingEnd - stakingStart;
        uint256 stakingFraction = timeStaked * 10**18 / stakingPeriod;
        uint256 dailyAPY = stakingAPY * 10**16 / 365;
        uint256 dailyEarnings = staked * dailyAPY / 10**18;
        uint256 totalEarnings = dailyEarnings * timeStaked / 1 days;
        uint256 earned = totalEarnings * stakingFraction / 10**18;

        return earned;
    }
}
