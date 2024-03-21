//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BlabToken is ERC20, Ownable(msg.sender) {
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * 10 ** 18;

    constructor() ERC20("BITSLAB", "BLAB") {
        _mint(address(this), TOTAL_SUPPLY);
    }
}
