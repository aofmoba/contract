// SPDX-License-Identifier: MIT

pragma solidity >0.4.9 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/*
  Disclaimer: Adopted from Opensea opensea-creatures repository
*/

// This is simply the IERC1155Factory interface
abstract contract Factory {
    function mint(
        uint256 _optionId,
        address _toAddress,
        uint256 _amount,
        bytes calldata _data
    ) external virtual;
}

/**
 * @title LootBoxRandomness
 * LootBoxRandomness- support for a randomized and openable lootbox.
 */
library LootBoxRandomness {
    using SafeMath for uint256;

    // Event for logging lootbox opens
    event LootBoxOpened(
        uint256 indexed optionId,
        address indexed buyer,
        uint256 boxesPurchased,
        uint256 itemsMinted
    );
    event Warning(string message, address account);

    uint256 constant INVERSE_BASIS_POINT = 10000;

    struct LootBoxRandomnessState {
        uint256 numOptions;
        uint256 numClasses;
        mapping(uint256 => uint16[]) classProbabilities;
        mapping(uint256 => uint256[]) classToTokenIds;
        mapping(uint256 => address) classToFactory;
        uint256 seed;
    }

    //////
    // INITIALIZATION FUNCTIONS FOR OWNER
    //////

    /**
     * @dev Set up the fields of the state that should have initial values.
     */
    function initState(
        LootBoxRandomnessState storage _state,
        uint256 _numOptions,
        uint256 _numClasses,
        uint256 _seed
    ) public {
        _state.numOptions = _numOptions;
        _state.numClasses = _numClasses;
        _state.seed = _seed;
    }

    /**
     * @dev Alternate way to add token ids to a class
     * Note: resets the full list for the class instead of adding each token id
     */
    function setTokenIdsForClass(
        LootBoxRandomnessState storage _state,
        uint256 _classId,
        uint256[] memory _tokenIds
    ) public {
        require(_classId < _state.numClasses, "_class out of range");
        _state.classToTokenIds[_classId] = _tokenIds;
    }

    function setFactoryForClass(
        LootBoxRandomnessState storage _state,
        uint256 _classId,
        address factory
    ) public {
        require(_classId < _state.numClasses, "_class out of range");
        _state.classToFactory[_classId] = factory;
    }

    /**
     * Set probilities per class
     */
    function setProbabilitiesForOption(
        LootBoxRandomnessState storage _state,
        uint256 _optionId,
        uint16[] memory probabilities
    ) public {
        _state.classProbabilities[_optionId] = probabilities;
    }

    /**
     * @dev Improve pseudorandom number generator by letting the owner set the seed manually,
     * making attacks more difficult
     * @param _newSeed The new seed to use for the next transaction
     */
    function setSeed(LootBoxRandomnessState storage _state, uint256 _newSeed) public {
        _state.seed = _newSeed;
    }

    ///////
    // MAIN FUNCTIONS
    //////

    /**
     * @dev Main minting logic for lootboxes
     */
    function _mint(
        LootBoxRandomnessState storage _state,
        uint256 _optionId,
        address _toAddress,
        uint256 _amount,
        bytes memory, /* _data */
        address _owner
    ) internal {
        require(_optionId < _state.numOptions, "_option out of range");
        uint256 quantityOfRandomized = 1;
        for (uint256 i = 0; i < _amount; i++) {
            // step 1. pick a class
            uint256 classId = _pickRandomClass(
                _state,
                _state.classProbabilities[_optionId]
            );
            // step 2. invoke mint from the corresponding factory to the class
            _sendTokenWithClass(
                _state,
                classId,
                _toAddress,
                quantityOfRandomized,
                _owner
            );
        }

        // Event emissions
        emit LootBoxOpened(_optionId, _toAddress, _amount, 1);
    }

    /////
    // HELPER FUNCTIONS
    /////

    // Returns the tokenId sent to _toAddress
    function _sendTokenWithClass(
        LootBoxRandomnessState storage _state,
        uint256 _classId,
        address _toAddress,
        uint256 _amount,
        address
    ) internal returns (uint256) {
        require(_classId < _state.numClasses, "_class out of range");
        Factory factory = Factory(_state.classToFactory[_classId]);
        // Always take the first token id for now
        uint256 tokenId = _state.classToTokenIds[_classId][0];
        // This may mint, create or transfer. We don't handle that here.
        // We use tokenId as an option ID here.
        factory.mint(tokenId, _toAddress, _amount, "");
        return tokenId;
    }

    // The core of the random picking algorithm, google "weighted random"
    function _pickRandomClass(
        LootBoxRandomnessState storage _state,
        uint16[] memory _classProbabilities
    ) internal returns (uint256) {
        uint16 value = uint16(_random(_state).mod(INVERSE_BASIS_POINT));
        // Start at top class (length - 1)
        // skip common (0), we default to it
        for (uint256 i = _classProbabilities.length - 1; i > 0; i--) {
            uint16 probability = _classProbabilities[i];
            if (value < probability) {
                return i;
            } else {
                value = value - probability;
            }
        }
        //FIXME: assumes zero is common!
        return 0;
    }

    /**
    function _pickRandomAvailableTokenIdForClass(
        LootBoxRandomnessState storage _state,
        uint256 _classId,
        uint256 _minAmount,
        address _owner
    ) internal returns (uint256) {
        require(_classId < _state.numClasses, "_class out of range");
        uint256[] memory tokenIds = _state.classToTokenIds[_classId];
        require(tokenIds.length > 0, "No token ids for _classId");
        uint256 randIndex = _random(_state).mod(tokenIds.length);
        // Make sure owner() owns or can mint enough
        Factory factory = Factory(_state.classToFactory[_classId]);
        for (uint256 i = randIndex; i < randIndex + tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i % tokenIds.length];
            // We use tokenId as an option id here
            if (factory.balanceOf(_owner, tokenId) >= _minAmount) {
                return tokenId;
            }
        }
        revert(
            "LootBoxRandomness#_pickRandomAvailableTokenIdForClass: NOT_ENOUGH_TOKENS_FOR_CLASS"
        );
    }
    */

    /**
     * @dev Pseudo-random number generator
     * NOTE: to improve randomness, generate it with an oracle
     */
    function _random(LootBoxRandomnessState storage _state)
        internal
        returns (uint256)
    {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1),
                    msg.sender,
                    _state.seed
                )
            )
        );
        _state.seed = randomNumber;
        return randomNumber;
    }
}
