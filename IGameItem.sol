pragma solidity ^0.8.0;

interface IGameItem {
    function purchaseGoods(address from,address to,uint256 tokenId,uint256 price) external;
    
}