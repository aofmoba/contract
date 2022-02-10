// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IGameItem {
    function purchaseGoods(address from,address to,uint256 tokenId,uint256 price) external;
    
}