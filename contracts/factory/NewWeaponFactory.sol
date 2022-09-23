// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../interfaces/IERC1155Factory.sol";
import "../CyberCard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../Counters.sol";

contract NewWeaponFactory is AccessControl, IERC1155Factory {
    using Counters for Counters.Counter;

    // address private spender;
    Counters.Counter private _tokenIdCounter;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address private cyberChar;

    uint256 prechain = 100000000;

    constructor(address _nftAddress) {
        cyberChar = _nftAddress;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }


    function mint(
        uint256 _optionId,
        address _to,
        uint256 _amount,
        bytes memory _data
    ) public override onlyRole(MINTER_ROLE) {

        _optionId = 1;
        _data = new bytes(1);
        uint256 id = _tokenIdCounter.current();
        require(_amount == 1, "cannot mint more than 1");
        CyberCard(cyberChar).safeMint(_to, id + 10000000  + prechain);
        _tokenIdCounter.increment();
    }
}
