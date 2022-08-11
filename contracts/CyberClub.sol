// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Cyber721.sol";

contract CyberClub is Cyber721 {
    constructor(uint256 idPrefix)
        Cyber721(
            idPrefix,
            "https://api.cyberpop.online/head/",
            "Cyber Club",
            "CBC"
        )
    {}
}
