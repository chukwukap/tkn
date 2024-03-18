// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Blab_Token.sol";

interface IPresale {
    function buyTokens(uint256 amount) external payable;

    function getCurrentStage() external view returns (uint256);

    function getStagePrice(uint256 stage) external view returns (uint256);

    function getStageSupply(uint256 stage) external view returns (uint256);

    function isPrivateSaleActive() external view returns (bool);

    function isWhitelisted(address account) external view returns (bool);
}

contract BlabPresale is IPresale, Ownable(msg.sender) {
    uint256 public constant STAGE1_SUPPLY = 20_000_000 * 10 ** 18;
    uint256 public constant STAGE2_SUPPLY = 20_000_000 * 10 ** 18;
    uint256 public constant STAGE3_SUPPLY = 40_000_000 * 10 ** 18;
    uint256 public constant STAGE4_SUPPLY = 40_000_000 * 10 ** 18;
    uint256 public constant STAGE5_SUPPLY = 40_000_000 * 10 ** 18;
    uint256 public constant STAGE6_SUPPLY = 40_000_000 * 10 ** 18;

    uint256 public constant STAGE1_PRICE = 2 * 10 ** 16; // $0.02
    uint256 public constant STAGE2_PRICE = 3 * 10 ** 16; // $0.03
    uint256 public constant STAGE3_PRICE = 5 * 10 ** 16; // $0.05
    uint256 public constant STAGE4_PRICE = 65 * 10 ** 15; // $0.065
    uint256 public constant STAGE5_PRICE = 85 * 10 ** 15; // $0.085
    uint256 public constant STAGE6_PRICE = 10 * 10 ** 17; // $0.10

    BlabToken blabToken;

    uint256 public currentStage = 1;
    uint256 public currentStageSupply;
    uint256 public currentStagePrice;

    uint256 public saleStartTime;
    uint256 public saleEndTime;

    bool public isPrivateSaleActiveNow = false;
    mapping(address => bool) public privateSaleWhitelist;

    constructor(BlabToken _blabToken) {
        blabToken = _blabToken;
        currentStageSupply = STAGE1_SUPPLY;
        currentStagePrice = STAGE1_PRICE;

        saleStartTime = 1717196400000; // 6/1/2024, 0:00:00 AM
        saleEndTime = 1718060424000; // 6/11/2024, 00:00:24 AM
    }

    function buyTokens(uint256 amount) external payable override {
        require(
            block.timestamp >= saleStartTime && block.timestamp <= saleEndTime,
            "Sale is not active"
        );
        require(msg.value >= amount * currentStagePrice, "Insufficient funds");
        require(currentStageSupply >= amount, "Insufficient token supply");

        if (isPrivateSaleActiveNow) {
            require(
                privateSaleWhitelist[msg.sender],
                "Not whitelisted for private sale"
            );
        }

        currentStageSupply -= amount;
    }

    function getCurrentStage() external view override returns (uint256) {
        return currentStage;
    }

    function getStagePrice(
        uint256 stage
    ) external view override returns (uint256) {
        if (stage == 1) {
            return STAGE1_PRICE;
        } else if (stage == 2) {
            return STAGE2_PRICE;
        } else if (stage == 3) {
            return STAGE3_PRICE;
        } else if (stage == 4) {
            return STAGE4_PRICE;
        } else if (stage == 5) {
            return STAGE5_PRICE;
        } else if (stage == 6) {
            return STAGE6_PRICE;
        }
        revert("Invalid stage");
    }

    function getStageSupply(
        uint256 stage
    ) external view override returns (uint256) {
        if (stage == 1) {
            return STAGE1_SUPPLY;
        } else if (stage == 2) {
            return STAGE2_SUPPLY;
        } else if (stage == 3) {
            return STAGE3_SUPPLY;
        } else if (stage == 4) {
            return STAGE4_SUPPLY;
        } else if (stage == 5) {
            return STAGE5_SUPPLY;
        } else if (stage == 6) {
            return STAGE6_SUPPLY;
        }
        revert("Invalid stage");
    }

    function isPrivateSaleActive() external view override returns (bool) {
        return isPrivateSaleActiveNow;
    }

    function isWhitelisted(
        address account
    ) external view override returns (bool) {
        return privateSaleWhitelist[account];
    }

    function togglePrivateSale(bool status) external onlyOwner {
        isPrivateSaleActiveNow = status;
    }

    function addToPrivateSaleWhitelist(
        address[] memory addresses
    ) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            privateSaleWhitelist[addresses[i]] = true;
        }
    }

    function removeFromPrivateSaleWhitelist(
        address[] memory addresses
    ) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            privateSaleWhitelist[addresses[i]] = false;
        }
    }

    function setCurrentStage(uint256 stage) external onlyOwner {
        require(stage >= 1 && stage <= 6, "Invalid stage");

        if (stage == 1) {
            currentStageSupply = STAGE1_SUPPLY;
            currentStagePrice = STAGE1_PRICE;
        } else if (stage == 2) {
            currentStageSupply = STAGE2_SUPPLY;
            currentStagePrice = STAGE2_PRICE;
        } else if (stage == 3) {
            currentStageSupply = STAGE3_SUPPLY;
            currentStagePrice = STAGE3_PRICE;
        } else if (stage == 4) {
            currentStageSupply = STAGE4_SUPPLY;
            currentStagePrice = STAGE4_PRICE;
        } else if (stage == 5) {
            currentStageSupply = STAGE5_SUPPLY;
            currentStagePrice = STAGE5_PRICE;
        } else if (stage == 6) {
            currentStageSupply = STAGE6_SUPPLY;
            currentStagePrice = STAGE6_PRICE;
        }

        currentStage = stage;
    }

    // function withdrawFunds() external onlyOwner {
    //     require(
    //         block.timestamp > claimDeadline,
    //         "Presale: Claim deadline has not passed yet"
    //     );
    //     payable(admin).transfer(address(this).balance);
    // }
}
