// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IMarket {
    
    function purchaseErc1155(address from,address to,uint256 tokenId,uint256 price,uint256 amount)  external;
    function sellNft(uint256 price,uint256 tokenId,uint256 amount) external;
    function purchaseErc1155WithUsdt(address from,address to,uint256 tokenId,uint256 price,uint256 amount)  external;

}