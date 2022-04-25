// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../interfaces/IERC1155Factory.sol";
import "../CyberpopGame.sol";
import "../utils/RNG.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ConsumerableFactory is AccessControl, IERC1155Factory, RNG {
    CyberpopGame private comsumerable;
    uint256[] private tokenIds;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address _comsumerableAddress, uint256[] memory _tokenIds) {
        comsumerable = CyberpopGame(_comsumerableAddress);
        tokenIds = _tokenIds;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function setCyberpopGame(address _address, uint256[] memory _tokenIds)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        comsumerable = CyberpopGame(_address);
        tokenIds = _tokenIds;
    }

    function mint(
        uint256 _optionId,
        address _to,
        uint256,
        bytes memory _data
    ) public override onlyRole(MINTER_ROLE) {
        uint256 id = tokenIds[_optionId];
        comsumerable.mint(_to, id, 1, _data);
    }
}