// SPDX-License-Identifier: MIT

pragma solidity >0.4.9 <0.9.0;

interface IERC721MintWithOption {
    /*
        @Dev in order to bind property of ERC721 to the ERC1155 token it minted from, we pass the optionId to the underline contract
        So that off-chain processor can connect the ERC1155 option with ERC721 token id by listening to a certain event.
        Check the implementation for more details
     */
    function safeMintWithOption(address _to, uint256 _optionId) external;
}
