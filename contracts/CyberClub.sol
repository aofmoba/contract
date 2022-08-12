// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "./Cyber721.sol";

contract CyberClub is Cyber721 {
    constructor(uint256 initId_)
        Cyber721(
            "https://api.cyberpop.online/head/",
            "Cyber Club",
            "CBC",
            initId_
        )
    {}
}
