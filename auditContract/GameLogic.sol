// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import  "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./IErc1155Asset.sol";
import "./ICyborg.sol";

contract GameLogic{
  
  address public owner;
  address public erc1155AssetAddress;
  address public nftAddress;
  address private signer;
  address private gamePoolAddress;
  bool _notEntered = true;

  event createGamePropeEvent(address indexed  player,uint256 tokenId,uint256 amount);
  event mergeToBdEvent(address from, uint256 newId);
  error Unauthorized(address caller);
  
   constructor(address signer_,address erc1155AssetAddress_ , address nftAddress_,address gamePoolAddress_){
      owner = msg.sender;
      erc1155AssetAddress = erc1155AssetAddress_;
      nftAddress = nftAddress_;
      signer = signer_;
      gamePoolAddress = gamePoolAddress_;
   }
    
    modifier nonReentrant() {
      require(_notEntered, "re-entered");
        _notEntered = false;
         _;
        _notEntered = true;
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
        ICyborg(nftAddress).safeMint(player,tokenId);   
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
      ICyborg(nftAddress).burn(tokenId);
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
          emit createGamePropeEvent(player,tokenIds[i],amounts[i]);
        }
       IErc1155Asset(erc1155AssetAddress).mintBatch(player, tokenIds, amounts, data);
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
          ICyborg(nftAddress).burn(ids[i]);
       }
       ICyborg(nftAddress).safeMint(player,newId);
   }
  
  // used by players to update the asset of erc1155
   function upgradePropeForErc1155(address player,uint256[] memory ids,uint256[] memory amounts,uint256 newId,uint256 newAmount)
    external{
     if(msg.sender != owner){
         revert Unauthorized(msg.sender);
       } 
      IErc1155Asset(erc1155AssetAddress).burnBatch(player,ids,amounts);
      IErc1155Asset(erc1155AssetAddress).mint(player,newId,newAmount,"");
   }
   
   /* @dev: Generate bd
   *  @param: newId: the id of bd. signature: The signature of the server. timestamp: The timestamp at the time the proof was generated
   */
  function mergeToBd(uint256 newId,bytes memory signature,string memory timestamp) public nonReentrant {
        require(checkPermissions(newId,signature,timestamp)==true,"You don't get the proof right");
        ICyborg(nftAddress).safeMint(gamePoolAddress,newId);
        emit mergeToBdEvent(msg.sender,newId);
    }
   
 //Convert parameter types from bytes to string
 function bytesToStr(bytes memory data) internal pure returns (string memory) {
    bytes memory alphabet = "0123456789abcdef";

    bytes memory str = new bytes(2 + data.length * 2);
    str[0] = "0";
    str[1] = "x";
    for (uint256 i = 0; i < data.length; i++) {
        str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
        str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
    }
      return string(str);
   }

  
   function strConcat(string memory str1, string memory str2,string memory str3) internal pure returns (string memory){
        bytes memory _str1 = bytes(str1);
        bytes memory _str2 = bytes(str2);
        bytes memory _str3 = bytes(str3);
        string memory ret = new string(_str1.length + _str2.length + _str3.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _str1.length; i++)bret[k++] = _str1[i];
        for (uint i = 0; i < _str2.length; i++) bret[k++] = _str2[i];
        for (uint i = 0; i < _str3.length; i++) bret[k++] = _str3[i];
        return string(ret);
   }  

  //Convert parameter types from address to string
    function addrToStr(address account) internal pure returns (string memory) {
      return bytesToStr(abi.encodePacked(account));
   }

    function getHash(address from,string memory newId,string memory timestamp) internal pure returns (bytes32 result){  
        return  ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked( strConcat( addrToStr(from),newId,timestamp ))));
     }  

   /* @dev: Check the correctness of the proof
   *  @param: newId: the id of bd. signature: The signature of the server. timestamp: The timestamp at the time the proof was generated
   */
    function checkPermissions(uint256 newId, bytes memory signature,string memory timestamp) internal view returns(bool) {
        return SignatureChecker.isValidSignatureNow(signer,getHash(msg.sender,Strings.toString(newId),timestamp),signature);
    }

}