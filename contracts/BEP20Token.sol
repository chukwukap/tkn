//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BLABToken is ERC20, Ownable {
    constructor() ERC20("BLAB Token", "BLAB") {
        _mint(msg.sender, 1000000000 * 10 ** 18); // 1 Billion tokens
    }
}
