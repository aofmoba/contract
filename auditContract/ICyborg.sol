// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface ICyborg{
    function safeMint(address to, uint256 tokenId) external;
    function burn(uint256 tokenId) external;
}