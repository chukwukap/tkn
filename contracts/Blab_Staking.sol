// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IStaking {
    function stake(uint256 amount) external;

    function unstake(uint256 amount) external;

    function getStakedBalance(address account) external view returns (uint256);
}

contract BlabStaking is IStaking, Ownable {
    mapping(address => uint256) public stakedBalances;

    function stake(uint256 amount) external override {
        stakedBalances[msg.sender] += amount;
    }

    function unstake(uint256 amount) external override {
        require(
            stakedBalances[msg.sender] >= amount,
            "Insufficient staked balance"
        );
        stakedBalances[msg.sender] -= amount;
    }

    function getStakedBalance(
        address account
    ) external view override returns (uint256) {
        return stakedBalances[account];
    }
}
