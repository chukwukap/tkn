// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/access/Ownable.sol";

// interface IPresale {
//     function buyTokens(uint256 amount) external payable;

//     function getCurrentStage() external view returns (uint256);

//     function getStagePrice(uint256 stage) external view returns (uint256);

//     function getStageSupply(uint256 stage) external view returns (uint256);

//     function presaleActive() external view returns (bool);

//     function isWhitelisted(address account) external view returns (bool);
// }

// contract BlabPresale is IPresale, Ownable {
//     uint256 public constant STAGE1_SUPPLY = 20_000_000 * 10 ** 18;
//     uint256 public constant STAGE2_SUPPLY = 20_000_000 * 10 ** 18;
//     uint256 public constant STAGE3_SUPPLY = 40_000_000 * 10 ** 18;
//     uint256 public constant STAGE4_SUPPLY = 40_000_000 * 10 ** 18;
//     uint256 public constant STAGE5_SUPPLY = 40_000_000 * 10 ** 18;
//     uint256 public constant STAGE6_SUPPLY = 40_000_000 * 10 ** 18;

//     uint256 public constant STAGE1_PRICE = 2 * 10 ** 16; // $0.02
//     uint256 public constant STAGE2_PRICE = 3 * 10 ** 16; // $0.03
//     uint256 public constant STAGE3_PRICE = 5 * 10 ** 16; // $0.05
//     uint256 public constant STAGE4_PRICE = 65 * 10 ** 15; // $0.065
//     uint256 public constant STAGE5_PRICE = 85 * 10 ** 15; // $0.085
//     uint256 public constant STAGE6_PRICE = 10 * 10 ** 17; // $0.10

//     uint256 public currentStage = 1;
//     uint256 public currentStageSupply;
//     uint256 public currentStagePrice;

//     uint256 public saleStartTime;
//     uint256 public saleEndTime;

//     bool public presaleActive = false;
//     mapping(address => bool) public privateSaleWhitelist;

//     constructor() {
//         currentStageSupply = STAGE1_SUPPLY;
//         currentStagePrice = STAGE1_PRICE;

//         saleStartTime = 1685638800; // June 1st, 2023, 00:00:00 UTC
//         saleEndTime = 1689840000; // July 11th, 2023, 23:59:59 UTC
//     }

//     function buyTokens(uint256 amount) external payable override {
//         require(
//             block.timestamp >= saleStartTime && block.timestamp <= saleEndTime,
//             "Sale is not active"
//         );
//         require(msg.value >= amount * currentStagePrice, "Insufficient funds");
//         require(currentStageSupply >= amount, "Insufficient token supply");

//         if (presaleActive) {
//             require(
//                 privateSaleWhitelist[msg.sender],
//                 "Not whitelisted for private sale"
//             );
//         }

//         currentStageSupply -= amount;
//     }

//     function getCurrentStage() external view override returns (uint256) {
//         return currentStage;
//     }

//     function getStagePrice(
//         uint256 stage
//     ) external view override returns (uint256) {
//         if (stage == 1) {
//             return STAGE1_PRICE;
//         } else if (stage == 2) {
//             return STAGE2_PRICE;
//         } else if (stage == 3) {
//             return STAGE3_PRICE;
//         } else if (stage == 4) {
//             return STAGE4_PRICE;
//         } else if (stage == 5) {
//             return STAGE5_PRICE;
//         } else if (stage == 6) {
//             return STAGE6_PRICE;
//         }
//         revert("Invalid stage");
//     }

//     function getStageSupply(
//         uint256 stage
//     ) external view override returns (uint256) {
//         if (stage == 1) {
//             return STAGE1_SUPPLY;
//         } else if (stage == 2) {
//             return STAGE2_SUPPLY;
//         } else if (stage == 3) {
//             return STAGE3_SUPPLY;
//         } else if (stage == 4) {
//             return STAGE4_SUPPLY;
//         } else if (stage == 5) {
//             return STAGE5_SUPPLY;
//         } else if (stage == 6) {
//             return STAGE6_SUPPLY;
//         }
//         revert("Invalid stage");
//     }

//     function isPresaleActive() external view override returns (bool) {
//         return presaleActive;
//     }

//     function isWhitelisted(
//         address account
//     ) external view override returns (bool) {
//         return privateSaleWhitelist[account];
//     }

//     function togglePrivateSale(bool status) external onlyOwner {
//         presaleActive = status;
//     }

//     function addToPrivateSaleWhitelist(
//         address[] memory addresses
//     ) external onlyOwner {
//         for (uint256 i = 0; i < addresses.length; i++) {
//             privateSaleWhitelist[addresses[i]] = true;
//         }
//     }

//     function removeFromPrivateSaleWhitelist(
//         address[] memory addresses
//     ) external onlyOwner {
//         for (uint256 i = 0; i < addresses.length; i++) {
//             privateSaleWhitelist[addresses[i]] = false;
//         }
//     }

//     function setCurrentStage(uint256 stage) external onlyOwner {
//         require(stage >= 1 && stage <= 6, "Invalid stage");

//         if (stage == 1) {
//             currentStageSupply = STAGE1_SUPPLY;
//             currentStagePrice = STAGE1_PRICE;
//         } else if (stage == 2) {
//             currentStageSupply = STAGE2_SUPPLY;
//             currentStagePrice = STAGE2_PRICE;
//         } else if (stage == 3) {
//             currentStageSupply = STAGE3_SUPPLY;
//             currentStagePrice = STAGE3_PRICE;
//         } else if (stage == 4) {
//             currentStageSupply = STAGE4_SUPPLY;
//             currentStagePrice = STAGE4_PRICE;
//         } else if (stage == 5) {
//             currentStageSupply = STAGE5_SUPPLY;
//             currentStagePrice = STAGE5_PRICE;
//         } else if (stage == 6) {
//             currentStageSupply = STAGE6_SUPPLY;
//             currentStagePrice = STAGE6_PRICE;
//         }

//         currentStage = stage;
//     }
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BEP20Token.sol";
import "./Ownable.sol"; // Import the Ownable contract

contract Presale is
    Ownable // Inherit from Ownable
{
    address public admin;
    BEP20Token public token;
    uint256 public totalRaised;
    uint256 public currentStage;
    uint256 public currentStageTokensLeft;
    uint256 public currentStageHardcap;
    uint256 public totalSold;
    uint256 public refundPool;
    mapping(address => uint256) public contributions;
    mapping(address => uint256) public refunds;
    uint256 public claimDeadline;

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 value);
    event RefundClaimed(address indexed user, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Presale: caller is not the admin");
        _;
    }

    constructor(address _tokenAddress) {
        admin = msg.sender;
        token = BEP20Token(_tokenAddress);
        currentStage = 0;
        setCurrentStageParams();
        // Set a default claim deadline (e.g., 30 days from contract deployment)
        claimDeadline = block.timestamp + 30 days;
    }

    function setCurrentStageParams() private {
        if (currentStage == 1) {
            currentStageTokensLeft =
                20_000_000 *
                (10 ** uint256(token.decimals()));
            currentStageHardcap = 400_000; // 400,000 BLAB
        } else if (currentStage == 2) {
            currentStageTokensLeft =
                20_000_000 *
                (10 ** uint256(token.decimals()));
            currentStageHardcap = 600_000; // 600,000 BLAB
        } else if (currentStage == 3) {
            currentStageTokensLeft =
                40_000_000 *
                (10 ** uint256(token.decimals()));
            currentStageHardcap = 1_600_000; // 1,600,000 BLAB
        } else if (currentStage == 4) {
            currentStageTokensLeft =
                40_000_000 *
                (10 ** uint256(token.decimals()));
            currentStageHardcap = 2_000_000; // 2,000,000 BLAB
        } else if (currentStage == 5) {
            currentStageTokensLeft =
                40_000_000 *
                (10 ** uint256(token.decimals()));
            currentStageHardcap = 2_400_000; // 2,400,000 BLAB
        } else if (currentStage == 6) {
            currentStageTokensLeft =
                40_000_000 *
                (10 ** uint256(token.decimals()));
            currentStageHardcap = 2_800_000; // 2,800,000 BLAB
        }
    }

    function buyTokens() external payable {
        require(
            currentStage > 0 && currentStage <= 6,
            "Presale: Presale has ended"
        );
        require(
            totalRaised + msg.value <= currentStageHardcap,
            "Presale: Hardcap reached for current stage"
        );

        uint256 tokensToBuy = (msg.value * 10 ** uint256(token.decimals())) /
            currentStagePrice;
        if (tokensToBuy > currentStageTokensLeft) {
            tokensToBuy = currentStageTokensLeft;
            refundPool +=
                (msg.value - (tokensToBuy * currentStagePrice)) /
                (10 ** uint256(token.decimals()));
        }

        require(tokensToBuy > 0, "Presale: No tokens to buy");

        token.transfer(msg.sender, tokensToBuy);
        totalRaised += msg.value;
        currentStageTokensLeft -= tokensToBuy;
        totalSold += tokensToBuy;
        contributions[msg.sender] += msg.value;

        emit TokensPurchased(msg.sender, tokensToBuy, msg.value);

        if (currentStageTokensLeft == 0) {
            increaseStage(); // Increase the stage when tokens are sold out
            setCurrentStageParams();
        }
    }

    function claimRefund() external {
        require(currentStage > 6, "Presale: Presale is not over yet");
        require(
            block.timestamp <= claimDeadline,
            "Presale: Claim deadline has passed"
        );
        uint256 userRefund = refunds[msg.sender];
        require(userRefund > 0, "Presale: No refund available for user");

        refunds[msg.sender] = 0;
        payable(msg.sender).transfer(userRefund);

        emit RefundClaimed(msg.sender, userRefund);
    }

    function withdrawFunds() external onlyAdmin {
        require(
            block.timestamp > claimDeadline,
            "Presale: Claim deadline has not passed yet"
        );
        payable(admin).transfer(address(this).balance);
    }

    function withdrawUnsoldTokens() external onlyAdmin {
        require(currentStage > 6, "Presale: Presale is not over yet");
        uint256 unsoldTokens = token.balanceOf(address(this));
        token.transfer(admin, unsoldTokens);
    }

    function withdrawClaimForCurrentStage() external {
        require(
            currentStage > 1 && currentStage <= 6,
            "Presale: Withdrawal not available for current stage"
        );

        uint256 userClaim = contributions[msg.sender];
        require(userClaim > 0, "Presale: No claim available for user");

        require(
            currentStage >= 2 && userClaim > 0,
            "Presale: No claim available for user"
        );

        contributions[msg.sender] = 0;
        refunds[msg.sender] += userClaim;

        emit RefundClaimed(msg.sender, userClaim);
    }

    // Function to increase the stage externally
    function increaseStage() external onlyOwner {
        require(currentStage < 6, "Presale: Already at the final stage");
        currentStage++;
    }
}
