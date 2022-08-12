// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./Cyber721.sol";

contract CyberCard is Cyber721 {
    constructor(uint256 initId_)
        Cyber721(
            "https://api.cyberpop.online/card/",
            "Cyberpop Support Card",
            "CBCA",
            initId_
        )
    {}
}
