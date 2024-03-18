//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BlabToken is ERC20, Ownable(msg.sender) {
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10 ** 18;

    uint256 public constant PUBLIC_PRESALE_SUPPLY = 200_000_000 * 10 ** 18;
    uint256 public constant PRIVATE_SALE_SUPPLY = 125_000_000 * 10 ** 18;
    uint256 public constant LIQUIDITY_SUPPLY = 75_000_000 * 10 ** 18;
    uint256 public constant AIRDROP_REWARDS_SUPPLY = 50_000_000 * 10 ** 18;
    uint256 public constant STAKING_POOL_SUPPLY = 165_000_000 * 10 ** 18;
    uint256 public constant ADVISORY_SUPPLY = 30_000_000 * 10 ** 18;
    uint256 public constant TEAM_SUPPLY = 80_000_000 * 10 ** 18;
    uint256 public constant ECOSYSTEM_SUPPLY = 90_000_000 * 10 ** 18;
    uint256 public constant EXCHANGE_RESERVES_SUPPLY = 140_000_000 * 10 ** 18;
    uint256 public constant DEV_MARKETING_SUPPLY = 45_000_000 * 10 ** 18;

    constructor() ERC20("BITSLAB", "BLAB") {
        _mint(address(this), TOTAL_SUPPLY);
    }
}
