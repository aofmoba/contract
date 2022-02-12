// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "./IMarket.sol";


contract router{

    address  private marketAddress;   

    constructor(address marketAddress_) {
        marketAddress = marketAddress_;
    }
 
    function purchaseGoods(address from,uint256 tokenId,uint256 price) public{
        
        IMarket(marketAddress).purchaseGoods(from,msg.sender,tokenId,price);
    }
    
}