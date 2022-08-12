// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./Cyber721.sol";

contract Cyborg is Cyber721 {
    address private _owner;

    constructor(uint256 initId_)
        Cyber721(
            "https://api.cyberpop.online/role/",
            "Cyborg",
            "CYBER",
            initId_
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
