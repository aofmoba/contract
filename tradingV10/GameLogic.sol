// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "./IErc1155Asset.sol";
import "./ICyborg.sol";

contract GameLogic {
  
  address public owner;
  address public erc1155AssetAddress;
  address public nftAddress;
  bool _notEntered = true;

  event createGamePropeEvent(address indexed  player,uint256 tokenId,uint256 amount);

  error Unauthorized(address caller);

   constructor(address erc1155AssetAddress_ , address nftAddress_){
      owner = msg.sender;
      erc1155AssetAddress = erc1155AssetAddress_;
      nftAddress = nftAddress_;
   }
    

    modifier nonReentrant() {
      require(_notEntered, "re-entered");
        _notEntered = false;
         _;
        _notEntered = true;
   }
   
   
   // this function is used create nft prope
   function createNft(address player,uint256 tokenId) 
        external{
           if(msg.sender != owner){
              revert Unauthorized(msg.sender);
           }
        ICyborg(nftAddress).safeMint(player,tokenId);   
   }



   function burn(uint256 tokenId) public{
        if(msg.sender != owner){
              revert Unauthorized(msg.sender);
       } 
      ICyborg(nftAddress).burn(tokenId);
   }

   // use createGamePrope can create new erc1155 prope
    function createGamePrope(address player,uint256 tokenId,uint256 amount,bytes memory data)
        public
        returns (uint256){
        if(msg.sender != owner){
            revert Unauthorized(msg.sender);
        } 
         IErc1155Asset(erc1155AssetAddress).mint(player, tokenId, amount, data);
         emit createGamePropeEvent(player,tokenId,amount);
        return tokenId;
    }

   
    function batchCreateGamePrope(address player,uint256 [] memory tokenIds,uint256[] memory amounts,uint64 length,bytes memory data)
     public
     returns(uint256[] memory tokendIds) {
      if(msg.sender != owner){
              revert Unauthorized(msg.sender);
       } 
      require(length== tokenIds.length && tokenIds.length == amounts.length ,"Array lengths do not match");


      for(uint i =0;i< length;i++){
          emit createGamePropeEvent(player,tokenIds[i],amounts[i]);
        }
       IErc1155Asset(erc1155AssetAddress).mintBatch(player, tokenIds, amounts, data);
        return tokenIds;
    }
  
   // metheds upgradePropeForNft only operate by owener
   function upgradePropeForNft(address player,uint256[] memory ids,uint256 newId)
   external{
      if(msg.sender != owner){
         revert Unauthorized(msg.sender);
       } 
       for(uint i=0;i<ids.length;i++){
          ICyborg(nftAddress).burn(ids[i]);
       }
       ICyborg(nftAddress).safeMint(player,newId);
   }
   
   function upgradePropeForErc1155(address player,uint256[] memory ids,uint256[] memory amounts,uint256 newId,uint256 newAmount)
    external{
     if(msg.sender != owner){
         revert Unauthorized(msg.sender);
       } 
      IErc1155Asset(erc1155AssetAddress).burnBatch(player,ids,amounts);
      IErc1155Asset(erc1155AssetAddress).mint(player,newId,newAmount,"");
   }
   

   function isValidSignatureNow(
        address signer,
        bytes32 hash,
        uint8 v,bytes32 r,bytes32 s
    ) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, v,r,s);
        if (error == ECDSA.RecoverError.NoError && recovered == signer) {
            return true;
        }
    }

   //this function can used by customer ,require customer  provide the proof
   function destroyOldIdToNewId (uint8 v,bytes32 r,bytes32 s,uint256[] memory ids,uint256 newId)
    external
    nonReentrant{
    bytes32 hash = keccak256(abi.encodePacked(msg.sender));
    isValidSignatureNow(owner,r,v,r,s);
   }

}