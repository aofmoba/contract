// SPDX-License-Identifier: MIT

pragma solidity >0.4.9 <0.9.0;

interface IERC1155Factory {
    /**
        @dev A factory that can mint on chain assets such as ERC20, ERC721, ERC1155.
             With a ERC1155 mint interface
        Mainly used by LootBoxRandomness to delegate the actual minting function
     */
    function mint(
        uint256 _optionId,
        address _to,
        uint256 _amount,
        bytes memory _data
    ) external;
}
