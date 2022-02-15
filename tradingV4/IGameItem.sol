// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IGameItem  {
    function showPropePrice(uint256 tokenId) external view returns(uint256);
}