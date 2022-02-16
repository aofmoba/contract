// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IMarket {
    
    function purchaseGoods(address from,address to,uint256 tokenId,uint256 price,uint256 amount)  external;
    function sellPrope(uint256 price,uint256 tokenId,uint256 amount,string calldata tokenUrl) external;
    function purchaseGoodsWithUsdt(address from,address to,uint256 tokenId,uint256 price,uint256 amount)  external;

}