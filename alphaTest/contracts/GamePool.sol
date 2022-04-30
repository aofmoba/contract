// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "./Proof.sol";

contract GamePool  is ERC1155Holder, ERC721Holder,Multicall,Context{

    address private erc1155GameAddress;
    address private roleAddress;
    address private owner;
    address private signer;
    address private cyt;
    address private coin;
    bool _notEntered = true;

    mapping(bytes => uint256) private proofMapping;
    
    error Unauthorized(address caller);

    event loadingRoleEvent(address from,uint256 tokenId,uint256 timeStamp);
    event loadingGamePropeEvent(address from,uint256 id,uint256 amount,uint256 timeStamp);
    
    event loadingCytEvent(address from, uint256 amount,uint256 timeStamp);
    event loadingCoinEvent(address from, uint256 amount,uint256 timeStamp);

    event withdrawGameProeEvent(address player,uint256[] ids,uint256[] amounts,uint256 timeStamp);
    event withdrawRoleEvent(address player,uint256 tokenId,uint256 timeStamp);

    event withdrawCytEVent(address player,uint256 amount,uint256 timeStamp);
    event withdrawCoinEvent(address player,uint256 amount,uint256 timeStamp);

    modifier nonReentrant() {
      require(_notEntered, "re-entered");
        _notEntered = false;
         _;
        _notEntered = true;
    }
   

    constructor(address signer_, address erc1155GameAddress_, address roleAddress_, address cyt_, address coin_){
     owner = _msgSender();
     signer = signer_;
     erc1155GameAddress = erc1155GameAddress_;
     roleAddress = roleAddress_;
     cyt = cyt_;
     coin = coin_;
   }
   

   /*
    * @dev:  Used by players to load the asset of cyt
    * @param: amout: the number of cyt
   */
   function loadingCyt(uint256 amount)external {
     IERC20(cyt).transferFrom(_msgSender(),address(this),amount);
     emit loadingCytEvent(_msgSender(),amount, block.timestamp); 
   }


   /*
    * @dev:  Used by players to load the asset of coin
    * @param: amout: the number of coin
   */
  function loadingCoin(uint256 amount) external{
     IERC20(coin).transferFrom(_msgSender(),address(this),amount);
     emit loadingCoinEvent(_msgSender(),amount, block.timestamp); 
  }

   /*
    * @dev:  Used by players to load the asset of erc721
    * @param: tokenId: The player wants to load the Id of the equipment
   */
    function loadingRole(uint256 tokenId)  external {
      IERC721(roleAddress).safeTransferFrom(_msgSender(),address(this),tokenId);
      emit loadingRoleEvent(_msgSender(),tokenId,block.timestamp);
    }

   /*
    * @dev:  Used by players to load the asset of erc1155
    * @param: tokenId: The player wants to load the Id of the equipment. amout: the amount of erc1155
   */
    function loadingGamePrope(
        uint256 id,
        uint256 amount) external {
      IERC1155(erc1155GameAddress).safeTransferFrom(_msgSender(),address(this),id,amount,"");
      emit loadingGamePropeEvent(_msgSender(),id,amount,block.timestamp);
    }

    /*@dev: player retrieve  cyt
     *@param: signature：proof of cyt. currentTimeStamp: timeStamp
    */ 
    function withdrawCyt(uint256 amount,bytes memory signature,uint256  currentTimeStamp)external nonReentrant {
      require(proofMapping[signature] == 0,"Proof has expired");
      require(Proof.checkPermissions(signer,amount,signature,currentTimeStamp,"ERC20_CYT")==true,"You don't get the proof right");
      IERC20(cyt).transfer(_msgSender(),amount);
      proofMapping[signature] = 1;        
      emit withdrawCytEVent(_msgSender(),amount,currentTimeStamp);
    }

    /*@dev: player retrieve  coin
     *@param: signature：proof of cyt. currentTimeStamp: timeStamp
    */ 
    function withdrawCoin(uint256 amount,bytes memory signature,uint256 currentTimeStamp) external nonReentrant{
      require(proofMapping[signature] == 0,"Proof has expired");
      require(Proof.checkPermissions(signer,amount,signature,currentTimeStamp,"ERC20_COIN")==true,"You don't get the proof right");
      IERC20(coin).transfer(_msgSender(),amount);
      proofMapping[signature] = 1;        
      emit withdrawCoinEvent(_msgSender(),amount,currentTimeStamp);
    }

   /* @dev:  player batch retrieves the asset of erc1155
    * @param: ids: the collection to retrieve the id . amounts: The number of ids to retrieve
    */
    function withdrawGameProbe(address player,uint256[] memory ids,uint256[] memory amounts) external{
          if(msg.sender != owner){
              revert Unauthorized(msg.sender);
           }
       IERC1155(erc1155GameAddress).safeBatchTransferFrom(address(this),player,ids,amounts,"0x"); 
       emit withdrawGameProeEvent(player,ids,amounts,block.timestamp);
    }


    /*@dev: player retrieves the nft
    * @param: tokenId: The player wants to load the Id of the equipment. amout: the amount of erc721
    */
    function withdrawRole(address player,uint256 tokenId) external{
      if(msg.sender != owner){
              revert Unauthorized(msg.sender);
           }
      IERC721(roleAddress).safeTransferFrom(address(this),player,tokenId);
      emit withdrawRoleEvent(player,tokenId,block.timestamp);     
    }
}