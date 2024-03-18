// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingContract is Ownable(msg.sender) {
    using SafeERC20 for IERC20;

    // Token contract address
    IERC20 public blabToken;

    // Staking duration (e.g., 30 days)
    uint256 public stakingDuration = 30 days;

    // Staking reward rate (e.g., 10% per year)
    uint256 public rewardRate = 10;

    // Mapping of user addresses to staking details
    mapping(address => Staker) public stakers;

    // Staker struct to store staking details
    struct Staker {
        uint256 amount;
        uint256 startTime;
        uint256 lastClaimTime;
    }

    // Event for token staking
    event TokensStaked(address indexed staker, uint256 amount);

    // Event for reward claim
    event RewardClaimed(address indexed staker, uint256 reward);

    constructor(address _tokenContract) {
        blabToken = IERC20(_tokenContract);
    }

    // Stake tokens
    function stakeTokens(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        blabToken.safeTransferFrom(msg.sender, address(this), _amount);

        Staker storage staker = stakers[msg.sender];
        if (staker.amount > 0) {
            claimReward(msg.sender);
        }

        staker.amount += _amount;
        staker.startTime = block.timestamp;
        staker.lastClaimTime = block.timestamp;

        emit TokensStaked(msg.sender, _amount);
    }

    // Unstake tokens
    function unstakeTokens() external {
        Staker storage staker = stakers[msg.sender];
        require(staker.amount > 0, "No tokens staked");

        uint256 reward = calculateReward(msg.sender);
        if (reward > 0) {
            blabToken.safeTransfer(msg.sender, reward);
            emit RewardClaimed(msg.sender, reward);
        }

        blabToken.safeTransfer(msg.sender, staker.amount);
        delete stakers[msg.sender];
    }

    // Claim reward
    function claimReward(address _staker) public {
        Staker storage staker = stakers[_staker];
        uint256 reward = calculateReward(_staker);
        if (reward > 0) {
            staker.lastClaimTime = block.timestamp;
            blabToken.safeTransfer(_staker, reward);
            emit RewardClaimed(_staker, reward);
        }
    }

    // Calculate reward
    function calculateReward(address _staker) public view returns (uint256) {
        Staker memory staker = stakers[_staker];
        if (staker.amount == 0 || staker.startTime == 0) {
            return 0;
        }

        uint256 elapsedTime = block.timestamp - staker.lastClaimTime;
        uint256 reward = (staker.amount * rewardRate * elapsedTime) /
            (100 * 365 days);
        return reward;
    }
}
