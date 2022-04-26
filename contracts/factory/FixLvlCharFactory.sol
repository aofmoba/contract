// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../interfaces/IERC1155Factory.sol";
import "./CharacterFactory.sol";
import "./ConsumerableFactory.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FixLvlCharFactory is AccessControl, IERC1155Factory {
    ConsumerableFactory private consumerableFactory;
    CharacterFactory private characterFactory;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(
        address consumerableFactoryAddress,
        address characterFactoryAddress
    ) {
        consumerableFactory = ConsumerableFactory(consumerableFactoryAddress);
        characterFactory = CharacterFactory(characterFactoryAddress);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function setConsumerableFactory(address _address)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        consumerableFactory = ConsumerableFactory(_address);
    }

    function setCharacterFactory(address _address)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        characterFactory = CharacterFactory(_address);
    }

    function mint(
        uint256 _optionId,
        address _to,
        uint256,
        bytes memory _data
    ) public override onlyRole(MINTER_ROLE) {
        if (_optionId == 0) {
            consumerableFactory.mint(0, _to, 1, _data);
        }
        if (_optionId == 1) {
            characterFactory.mint(1, _to, 1, _data);
        }
    }
}
