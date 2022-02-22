// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IGameItem.sol";
import "./IErc1155Asset.sol";

contract GameItem is IGameItem{
  
  address public owner;
  address public erc1155AssetAddress;
  bool _notEntered = true;

  event createGamePropeEvent(address indexed  player,uint256 tokenId,uint256 amount,string tokenURI);

   constructor(address erc1155AssetAddress_){
      owner = msg.sender;
      erc1155AssetAddress = erc1155AssetAddress_;
   }
    
    //防止重入攻击
    modifier nonReentrant() {
      require(_notEntered, "re-entered");
        _notEntered = false;
         _;
        _notEntered = true;
   }

   modifier onlyOwner() {
      require(owner == msg.sender, "no permision");
         _;
        
   }
 
    function createGamePrope(address player,string memory tokenUrl,uint256 tokenId,uint256 amount,bytes memory data)
        public
        onlyOwner
        nonReentrant
        returns (uint256){
         IErc1155Asset(erc1155AssetAddress).mint(player, tokenId, amount, data);
         emit createGamePropeEvent(player,tokenId,amount,tokenUrl);
        return tokenId;
    }

 
    function batchCreateGamePrope(address player,string[] memory tokensUrl,uint256 [] memory tokenIds,uint256[] memory amounts,uint64 length,bytes memory data)
     public
     onlyOwner
     nonReentrant
     returns(uint256[] memory tokendIds) {
        require(length == tokensUrl.length && tokensUrl.length == tokenIds.length && tokenIds.length == amounts.length ,"Array lengths do not match");
        for(uint i =0;i< length;i++){
          emit createGamePropeEvent(player,tokenIds[i],amounts[i],tokensUrl[i]);
        }
       IErc1155Asset(erc1155AssetAddress).mintBatch(player, tokenIds, amounts, data);
        return tokenIds;
    }
  
   function upgradePrope(address player,uint256[] memory ids,uint256[] memory amounts)external{
      IErc1155Asset(erc1155AssetAddress).burnBatch(player,ids,amounts);
   }
}