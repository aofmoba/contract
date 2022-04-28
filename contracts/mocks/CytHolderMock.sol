// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract CytHolderMock {
    function onTokenTransfer(
        address from,
        address to,
        uint256 amount,
        bytes memory data
    ) public returns (bool) {}
}
