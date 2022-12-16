// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./Proof.sol";
import "./IErc1155Asset.sol";
import "./ICyborg.sol";

contract GamePool  is ERC1155Holder, ERC721Holder,Multicall,Context{

    address private owner;
    address private signer;
    bool _notEntered = true;
    uint256 public timeStampProof;

    mapping(bytes => uint256) private proofMapping;
    
    error Unauthorized(address caller);

    event loadingErc20Event(address  tokenAddress,address from, uint256 amount,uint256 timeStamp);
    event loadingErc721Event(address  tokenAddress,address from,uint256 tokenId,uint256 timeStamp);
    event loadingErc1155Event(address  tokenAddress,address from,uint256 id,uint256 amount,uint256 timeStamp);


   event withdrawErc20EVent(uint chainId,address tokenAddress,address player,uint256 amount,uint256 timeStamp);
   event withdrawErc721Event(uint chainId ,address tokenAddress,address player,uint256 tokenId,uint256 timeStamp);
   event WithdrawErc1155Event(uint chainId, address tokenAddress,address player,uint256 id,uint256 amount,uint256 timeStamp);

   event gameUpgradeEvent(uint chainId,address tokenAddress,address account,uint256[] id, uint256[] value, uint256 newId, uint256 amount);
   event roleUpgradeEvent(uint chainId,address tokenAddress,address account,uint256[] id, uint256 newId);


    modifier nonReentrant() {
      require(_notEntered, "re-entered");
        _notEntered = false;
         _;
        _notEntered = true;
    }

  modifier updateProof(uint256 timeStampProof_) {
      require(timeStampProof_ >= timeStampProof, "error: time of proof");
         _;
      timeStampProof = timeStampProof_;
    }
    
    constructor(address signer_){
     owner = _msgSender();
     signer = signer_;
   }

   /*
    * @dev:  Used by players to load the asset of erc20
    * @param: amout: the number of Erc20
   */
   function loadingErc20(address tokenAddress,uint256 amount)external {
     IERC20(tokenAddress).transferFrom(_msgSender(),address(this),amount);
     emit loadingErc20Event(tokenAddress,_msgSender(),amount, block.timestamp); 
   }

   /*
    * @dev:  Used by players to load the asset of erc721
    * @param: tokenId: The player wants to load the Id of the equipment
   */
    function loadingErc721(address tokenAddress,uint256 tokenId)  external {
      IERC721(tokenAddress).safeTransferFrom(_msgSender(),address(this),tokenId);
      emit loadingErc721Event(tokenAddress,_msgSender(),tokenId,block.timestamp);
    }

   /*
    * @dev:  Used by players to load the asset of erc1155
    * @param: tokenId: The player wants to load the Id of the equipment. amout: the amount of erc1155
   */
    function loadingErc1155(
        address tokenAddress,
        uint256 id,
        uint256 amount) external {
      IERC1155(tokenAddress).safeTransferFrom(_msgSender(),address(this),id,amount,"");
      emit loadingErc1155Event(tokenAddress,_msgSender(),id,amount,block.timestamp);
    }


    /*@dev: player retrieve  erc20 asset
     *@param: signature：proof of erc20. currentTimeStamp: timeStamp
    */ 
    function withdrawErc20(address tokenAddress,uint256 amount,bytes memory signature,uint256 currentTimeStamp,uint chainId) external nonReentrant updateProof(currentTimeStamp){
      require(chainId == block.chainid,"misMatched chinId ");
      require(proofMapping[signature] == 0,"Proof has expired");
      require(Proof.checkPermissions(signer,amount,signature,currentTimeStamp,Proof.addrToStr(tokenAddress),chainId)==true,"You don't get the proof right");
      IERC20(tokenAddress).transfer(_msgSender(),amount);
      proofMapping[signature] = 1;        
      emit withdrawErc20EVent(block.chainid,tokenAddress,_msgSender(),amount,currentTimeStamp);
    }
    

    /* @dev:  player retrieve the asset of erc1155
    * @param: ids: the collection to retrieve the id . amounts: The number of ids to retrieve
    */
    function WithdrawErc1155(address tokenAddress,address player,uint256  id,uint256  amount,bytes memory signature,uint256 currentTimeStamp,uint chainId) external nonReentrant updateProof(currentTimeStamp){
      require(chainId == block.chainid,"misMatched chinId ");
      require(proofMapping[signature] == 0,"Proof has expired");
      require(Proof.checkPermissions(signer,id,amount,signature,currentTimeStamp,Proof.addrToStr(tokenAddress),chainId)==true,"You don't get the proof right");
       IERC1155(tokenAddress).safeTransferFrom(address(this),player,id,amount,"0x"); 
         proofMapping[signature] = 1;
       emit WithdrawErc1155Event(block.chainid,tokenAddress,player,id,amount,block.timestamp);
    }

    /*@dev: player retrieves the erc721
    * @param: tokenId: The player wants to load the Id of the equipment. amout: the amount of erc721
    */
    function withdrawErc721(address tokenAddress,address player,uint256 tokenId,bytes memory signature,uint256 currentTimeStamp,uint chainId) external nonReentrant updateProof(currentTimeStamp){
      require(chainId == block.chainid,"misMatched chinId ");
      require(proofMapping[signature] == 0,"Proof has expired");
      require(Proof.checkPermissions(signer,tokenId,signature,currentTimeStamp,Proof.addrToStr(tokenAddress),chainId)==true,"You don't get the proof right");
      IERC721(tokenAddress).safeTransferFrom(address(this),player,tokenId);
        proofMapping[signature] = 1;
      emit withdrawErc721Event(block.chainid,tokenAddress,player,tokenId,block.timestamp);     
    }

   function checkPermissionForGameUpgrade(uint256[] memory oldIds,uint256[] memory oldAmounts, uint256 newId, uint256 amount,address tokenAddress,uint256[] memory currentTimeStamp,uint chainId,bytes[] memory signature) internal view returns(bool){
     require(oldIds.length == oldAmounts.length && oldAmounts.length == currentTimeStamp.length && currentTimeStamp.length == signature.length,"array lenth must matched");
     for(uint i =0;i<oldIds.length;i++){

      if(proofMapping[signature[i]] == 1){
         return false;
       }
       if(Proof.checkPermissions(oldIds[i],oldAmounts[i],newId,amount,tokenAddress,currentTimeStamp[i],chainId,signer,signature[i])==false){
         return false;
       }
     }
      return true;
   }

   function checkPermissionForRoleUpgrade(address tokenAddress,uint256[] memory oldIds,uint256 newId,uint256[] memory currentTimeStamp,uint chainId,bytes[] memory signature) internal view returns(bool){
      require(oldIds.length == currentTimeStamp.length && currentTimeStamp.length == signature.length,"array lenth must matched");
     for(uint i =0;i<oldIds.length;i++){

      if(proofMapping[signature[i]] == 1){
         return false;
       }
      if(Proof.checkPermissions(signer,oldIds[i],newId,signature[i],currentTimeStamp[i],Proof.addrToStr(tokenAddress),chainId)==false){
        return false;
      }
        
     }
      return true;
   }


 /* @dev: upgrade game prop
   *  @param: id: the old id, value: number of gamePrope, newId: the new Id, amount: the number of new Id
   */
  function gameUpgrade(uint256[] memory oldIds,uint256[] memory oldAmounts, uint256 newId, uint256 amount,address tokenAddress,uint256[] memory currentTimeStamp,uint256 chainId,bytes[] memory signature) external nonReentrant updateProof(currentTimeStamp[currentTimeStamp.length-1]) {
        require(chainId == block.chainid,"misMatched chinId ");
        require(checkPermissionForGameUpgrade(oldIds,oldAmounts,newId,amount,tokenAddress,currentTimeStamp,chainId,signature) == true ,"You don't get the proof right");
        IErc1155Asset(tokenAddress).burnBatch(msg.sender,oldIds,oldAmounts);
        IErc1155Asset(tokenAddress).mint(msg.sender,newId,amount,"0x");
	      for(uint i =0 ;i<signature.length;i++){
  	     proofMapping[signature[i]] == 1;
	}
        emit gameUpgradeEvent(block.chainid,tokenAddress,msg.sender,oldIds,oldAmounts,newId,amount);
   }

 /* @dev: upgrade role
   *  @param: id: the old id,  newId: the new Id, amount: the number of new Id
   */

  function roleUpgrade(uint256[] memory oldIds,address tokenAddress,uint256 newId,uint256[] memory currentTimeStamp,uint256 chainId,bytes[] memory signature) external nonReentrant updateProof(currentTimeStamp[currentTimeStamp.length-1]){
       require(chainId == block.chainid,"misMatched chinId ");
       require(checkPermissionForRoleUpgrade(tokenAddress,oldIds,newId,currentTimeStamp,chainId,signature) == true ,"You don't get the proof right");
        for(uint i = 0;i<oldIds.length;i++){
          ICyborg(tokenAddress).burn(oldIds[i]);
            proofMapping[signature[i]] == 1;

        }
          ICyborg(tokenAddress).safeMint(msg.sender,newId);
        emit roleUpgradeEvent(chainId,tokenAddress,msg.sender,oldIds,newId);
  }

    /*@dev:  set the start time of proof
    */
  function setTimeStampProof(uint256 timeStampProof_) external{
      if(msg.sender != owner){
              revert Unauthorized(msg.sender);
       } 
    timeStampProof = timeStampProof_; 
  }


}