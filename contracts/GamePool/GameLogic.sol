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
  address public GameAddress;
  address public roleAddress;
  address private signer;
  bool _notEntered = true;
  uint256 public timeStampProof;

  mapping(bytes => uint256) private proofMapping;  


  event createGameEvent(address indexed  player,uint256 tokenId,uint256 amount);
  event mergeToBdEvent(uint chainId,address from, uint256 newId);
  event gameUpgradeEvent(uint chainId,address account,uint256[] id, uint256[] value, uint256 newId, uint256 amount);
  error Unauthorized(address caller);
  
   constructor(address signer_,address GameAddress_ , address roleAddress_){
      owner = msg.sender;
      GameAddress = GameAddress_;
      roleAddress = roleAddress_;
      signer = signer_;
      timeStampProof  =  block.timestamp;
   }
    
    modifier nonReentrant() {
      require(_notEntered, "re-entered");
        _notEntered = false;
         _;
        _notEntered = true;
   }
   
   
  modifier updateProof(uint256 timeStampProof_) {
      require(timeStampProof_ >= timeStampProof, "error: time of proof");
         _;
    }
   

   /* @dev: Generate bd
   *  @param: newId: the id of bd. signature: The signature of the server. timestamp: The timestamp at the time the proof was generated
   */
   function mergeToBd(uint256 newId,bytes memory signature,uint256  currentTimeStamp,uint256 chainId) external nonReentrant updateProof(currentTimeStamp) {
        require(chainId == block.chainid,"misMatched chinId ");
        require(proofMapping[signature] == 0,"Proof has expired");
        require(Proof.checkPermissions(signer,newId,signature,currentTimeStamp,"ERC721_Role",chainId)==true,"You don't get the proof right");
        ICyborg(roleAddress).safeMint(msg.sender,newId);
        proofMapping[signature] = 1;        
        emit mergeToBdEvent(block.chainid,msg.sender,newId);
    }


 /* @dev: upgrade game prop
   *  @param: oldIds: the old id, oldAmounts: number of gamePrope, newId: the new Id, amount: the number of new Id
   */
   function gameUpgrade(uint256[] memory oldIds,uint256[] memory oldAmounts,uint256 newId, uint256 amount) external {
        IErc1155Asset(GameAddress).burnBatch(msg.sender,oldIds,oldAmounts);
        IErc1155Asset(GameAddress).mint(msg.sender,newId,amount,"0x");
        emit gameUpgradeEvent(block.chainid,msg.sender,oldIds,oldAmounts,newId,amount);
   }


   /*
    * @dev: create a nft by owner 
    * @param:  payer: the address of player. tokenId: the id of prope
   */
   function createRole(address player,uint256 tokenId) 
        external{
           if(msg.sender != owner){
              revert Unauthorized(msg.sender);
           }
        ICyborg(roleAddress).safeMint(player,tokenId);   
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
         IErc1155Asset(GameAddress).mint(player, tokenId, amount, data);
         emit createGameEvent(player,tokenId,amount);
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
          emit createGameEvent(player,tokenIds[i],amounts[i]);
        }
       IErc1155Asset(GameAddress).mintBatch(player, tokenIds, amounts, data);
        return tokenIds;
    }
  
}
