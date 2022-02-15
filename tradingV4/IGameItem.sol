// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IGameItem  {
    function showPropePrice(uint256 tokenId) external view returns(uint256);
    function  balanceOf_(address account, uint256 id) external view returns(uint256);
    function safeTransferFrom_(address from,address to,uint256 id,uint256 amount, bytes memory data) external;
}