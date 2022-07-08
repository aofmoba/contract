// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../factory/ConsumerableFactory.sol";

contract GameItemFactory is ConsumerableFactory {
    constructor(address _consumerableAddress, uint256[] memory _tokenIds)
        ConsumerableFactory(_consumerableAddress, _tokenIds)
    {}
}
