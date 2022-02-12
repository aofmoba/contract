// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IMarket {
    function purchaseGoods(address from,address to,uint256 tokenId,uint256 price)  external;
    function sellPrope(address account,uint256 price,uint256 tokenId,uint256 amount,string calldata tokenUrl) external;
    
}