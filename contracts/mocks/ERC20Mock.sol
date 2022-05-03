// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor() ERC20("ERC20 Mock", "MYT") {
        _mint(msg.sender, 10e6);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}
