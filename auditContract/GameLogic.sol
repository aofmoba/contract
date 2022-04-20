// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import  "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./IErc1155Asset.sol";
import "./ICyborg.sol";
import "./Proof.sol";

contract GameLogic{
  
  address public owner;
  address public erc1155WeaponsAddress;
  address public roleAddress;
  address private signer;
  address private gamePoolAddress;
  bool _notEntered = true;
  uint256 public blockTimestampLast;


  event createWeaponsEvent(address indexed  player,uint256 tokenId,uint256 amount);
  event mergeToBdEvent(address from, uint256 newId);
  error Unauthorized(address caller);
  
   constructor(address signer_,address erc1155WeaponsAddress_ , address roleAddress_,address gamePoolAddress_){
      owner = msg.sender;
      erc1155WeaponsAddress = erc1155WeaponsAddress_;
      roleAddress = roleAddress_;
      signer = signer_;
      gamePoolAddress = gamePoolAddress_;
   }
    
    modifier nonReentrant() {
      require(_notEntered, "re-entered");
        _notEntered = false;
         _;
        _notEntered = true;
   }
   
   
   /* @dev: Generate bd
   *  @param: newId: the id of bd. signature: The signature of the server. timestamp: The timestamp at the time the proof was generated
   */
   function mergeToBd(uint256 newId,bytes memory signature,uint256  currentTimeStamp) public nonReentrant {
        require(currentTimeStamp > blockTimestampLast,"the proof has expired");
        require(Proof.checkPermissions(signer,newId,signature,currentTimeStamp,"ERC721_bd")==true,"You don't get the proof right");
        ICyborg(roleAddress).safeMint(gamePoolAddress,newId);
        blockTimestampLast = currentTimeStamp;
        emit mergeToBdEvent(msg.sender,newId);
    }

   /*
    * @dev: create a nft by owner 
    * @param:  payer: the address of player. tokenId: the id of prope
   */
   function createNft(address player,uint256 tokenId) 
        external{
           if(msg.sender != owner){
              revert Unauthorized(msg.sender);
           }
        ICyborg(roleAddress).safeMint(player,tokenId);   
   }

    /**
     * @dev Destroys  the tokens of token type `tokenId` from `msg.sender`
     *
     * Requirements:
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
   function burn(uint256 tokenId) public{
        if(msg.sender != owner){
              revert Unauthorized(msg.sender);
       } 
      ICyborg(roleAddress).burn(tokenId);
   }

     /**
     * @dev Creates `amount` tokens of token type `tokenId`, and assigns them to player.
     *
     * Emits a  createGamePrope event.
     *
     * Requirements:
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function createWeapons(address player,uint256 tokenId,uint256 amount,bytes memory data)
        public
        returns (uint256){
        if(msg.sender != owner){
            revert Unauthorized(msg.sender);
        } 
         IErc1155Asset(erc1155WeaponsAddress).mint(player, tokenId, amount, data);
         emit createWeaponsEvent(player,tokenId,amount);
        return tokenId;
    }
   
    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function batchCreateGamePrope(address player,uint256 [] memory tokenIds,uint256[] memory amounts,uint64 length,bytes memory data)
     public
     returns(uint256[] memory tokendIds) {
      if(msg.sender != owner){
              revert Unauthorized(msg.sender);
       } 
      require(length== tokenIds.length && tokenIds.length == amounts.length ,"Array lengths do not match");


      for(uint i =0;i< length;i++){
          emit createWeaponsEvent(player,tokenIds[i],amounts[i]);
        }
       IErc1155Asset(erc1155WeaponsAddress).mintBatch(player, tokenIds, amounts, data);
        return tokenIds;
    }
  
  /*@dev: Used by players to update the asset of erc721
  * @param:  payer: the address of player. ids: burn off the ids  newId: newId after successful upgrade
  */
   function upgradePropeForNft(address player,uint256[] memory ids,uint256 newId)
   external{
      if(msg.sender != owner){
         revert Unauthorized(msg.sender);
       } 
       for(uint i=0;i<ids.length;i++){
          ICyborg(roleAddress).burn(ids[i]);
       }
       ICyborg(roleAddress).safeMint(player,newId);
   }
  
  // used by players to update the asset of erc1155
   function upgradePropeForErc1155(address player,uint256[] memory ids,uint256[] memory amounts,uint256 newId,uint256 newAmount)
    external{
     if(msg.sender != owner){
         revert Unauthorized(msg.sender);
       } 
      IErc1155Asset(erc1155WeaponsAddress).burnBatch(player,ids,amounts);
      IErc1155Asset(erc1155WeaponsAddress).mint(player,newId,newAmount,"");
   }
}