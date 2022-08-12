// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../interfaces/IERC1155Factory.sol";
import "./CharacterFactory.sol";
import "./ConsumerableFactory.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../Counters.sol";

contract FixLvlCharFactory is AccessControl, IERC1155Factory {
    ConsumerableFactory private consumerableFactory;
    CharacterFactory private characterFactory;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public _numOptions;
    constructor(
        address consumerableFactoryAddress,
        address characterFactoryAddress,
        uint256 numOptions
    ) {
        consumerableFactory = ConsumerableFactory(consumerableFactoryAddress);
        characterFactory = CharacterFactory(characterFactoryAddress);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _numOptions = numOptions;
    }

    function setNumOptions(uint256 _num) public onlyRole(DEFAULT_ADMIN_ROLE) {
      _numOptions = _num;
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
        require(_optionId < _numOptions, "FixLvlCharFactory: unexpected optionId");
        if (_optionId == 0) {
            consumerableFactory.mint(0, _to, 1, _data);
        } else {
            characterFactory.mint(_optionId - 1, _to, 1, _data);
        }
    }
}
