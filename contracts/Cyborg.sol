// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Cyber721.sol";

contract Cyborg is Cyber721 {
    address private _owner;

    constructor(uint256 idPrefix)
        Cyber721(
            idPrefix,
            "https://api.cyberpop.online/role/",
            "Cyborg",
            "CYBER"
        )
    {
        _owner = _msgSender();
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function _setOwner() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _owner = _msgSender();
    }
}
