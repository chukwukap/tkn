// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PresaleToken is Ownable {
   uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10**18; // 1 billion tokens

   uint256 public constant PUBLIC_PRESALE_SUPPLY = 200_000_000 * 10**18; // 20%
   uint256 public constant PRIVATE_SALE_SUPPLY = 125_000_000 * 10**18; // 12.5%
   uint256 public constant LIQUIDITY_SUPPLY = 75_000_000 * 10**18; // 7.5%
   uint256 public constant AIRDROP_REWARDS_SUPPLY = 50_000_000 * 10**18; // 5%
   uint256 public constant STAKING_POOL_SUPPLY = 165_000_000 * 10**18; // 16.5%
   uint256 public constant ADVISORY_SUPPLY = 30_000_000 * 10**18; // 3%
   uint256 public constant TEAM_SUPPLY = 80_000_000 * 10**18; // 8%
   uint256 public constant ECOSYSTEM_SUPPLY = 90_000_000 * 10**18; // 9%
   uint256 public constant EXCHANGE_RESERVES_SUPPLY = 140_000_000 * 10**18; // 14%
   uint256 public constant DEVELOPMENT_MARKETING_SUPPLY = 45_000_000 * 10**18; // 4.5%

   uint256 public constant PRESALE_STAGE_1_SUPPLY = 20_000_000 * 10**18;
   uint256 public constant PRESALE_STAGE_1_PRICE = 0.02 * 10**18; // $0.02 per token
   uint256 public constant PRESALE_STAGE_1_HARDCAP = 400_000 * 10**18; // $400,000

   uint256 public constant PRESALE_STAGE_2_SUPPLY = 20_000_000 * 10**18;
   uint256 public constant PRESALE_STAGE_2_PRICE = 0.03 * 10**18; // $0.03 per token
   uint256 public constant PRESALE_STAGE_2_HARDCAP = 600_000 * 10**18; // $600,000

   // Add more presale stage constants for stages 3-6
   ERC20 private token;
   uint256 public presaleStage = 0;
   uint256 public presaleStartTime;
   uint256 public presaleEndTime;

   mapping(uint256 => uint256) public stageTotalRaised;

   event PresaleStageStarted(uint256 stage, uint256 startTime, uint256 endTime);
   event TokensPurchased(address indexed buyer, uint256 amount, uint256 stage);

   constructor(address _tokenAddress) {
    token = ERC20(_tokenAddress)
       _mint(address(this), TOTAL_SUPPLY);
   }

   function startPresaleStage(uint256 _stage, uint256 _startTime, uint256 _endTime) external onlyOwner {
       require(_stage > 0 && _stage <= 6, "Invalid presale stage");
       require(_startTime < _endTime, "Invalid time range");
       presaleStage = _stage;
       presaleStartTime = _startTime;
       presaleEndTime = _endTime;
       emit PresaleStageStarted(_stage, _startTime, _endTime);
   }

   function buyTokens(uint256 _amount) external payable {
       require(presaleStage > 0 && presaleStage <= 6, "Presale not active");
       require(block.timestamp >= presaleStartTime && block.timestamp <= presaleEndTime, "Presale not open");

       uint256 tokenPrice;
       uint256 supplyLimit;
       uint256 hardcap;

       if (presaleStage == 1) {
           tokenPrice = PRESALE_STAGE_1_PRICE;
           supplyLimit = PRESALE_STAGE_1_SUPPLY;
           hardcap = PRESALE_STAGE_1_HARDCAP;
       } else if (presaleStage == 2) {
           tokenPrice = PRESALE_STAGE_2_PRICE;
           supplyLimit = PRESALE_STAGE_2_SUPPLY;
           hardcap = PRESALE_STAGE_2_HARDCAP;
       }

       require(_amount * tokenPrice <= hardcap - stageTotalRaised[presaleStage], "Hardcap reached");
       require(_amount * tokenPrice <= msg.value, "Insufficient ETH sent");
       require(_amount <= supplyLimit - totalSupply(), "Insufficient token supply");

       stageTotalRaised[presaleStage] += _amount * tokenPrice;
       _transfer(address(this), msg.sender, _amount);

       emit TokensPurchased(msg.sender, _amount, presaleStage);
   }

   function withdrawEther(uint256 _amount) external onlyOwner {
       require(_amount <= address(this).balance, "Insufficient balance");
       payable(owner()).transfer(_amount);
   }

   function distributeTokens() external onlyOwner {
       _transfer(address(this), /*public presale address*/, PUBLIC_PRESALE_SUPPLY);
       _transfer(address(this), /*private sale address*/, PRIVATE_SALE_SUPPLY);
       _transfer(address(this), /*liquidity address*/, LIQUIDITY_SUPPLY);
       _transfer(address(this), /*airdrop & rewards address*/, AIRDROP_REWARDS_SUPPLY);
       _transfer(address(this), /*staking pool address*/, STAKING_POOL_SUPPLY);
       _transfer(address(this), /*advisory address*/, ADVISORY_SUPPLY);
       _transfer(address(this), /*team address*/, TEAM_SUPPLY);
       _transfer(address(this), /*ecosystem address*/, ECOSYSTEM_SUPPLY);
       _transfer(address(this), /*exchange reserves address*/, EXCHANGE_RESERVES_SUPPLY);
       _transfer(address(this), /*development & marketing address*/, DEVELOPMENT_MARKETING_SUPPLY);
   }
}