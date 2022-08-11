// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Cyber721.sol";

contract CyberCard is Cyber721 {
    constructor(uint256 idPrefix)
        Cyber721(
            idPrefix,
            "https://api.cyberpop.online/card/",
            "Cyberpop Support Card",
            "CBCA"
        )
    {}
}
