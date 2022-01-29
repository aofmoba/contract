pragma solidity ^0.8.0;
import "./IGameItem.sol";


contract router{

    address  private gameItemAddress;   

    constructor(address gameItemAddress_) {
        gameItemAddress = gameItemAddress_;
    }
  
    function purchaseGoods(address from,uint256 tokenId,uint256 price) public{
        
        IGameItem(gameItemAddress).purchaseGoods(from,msg.sender,tokenId,price);
    }
    
}