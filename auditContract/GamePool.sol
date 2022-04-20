// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "./Proof.sol";

contract GamePool  is ERC1155Holder, ERC721Holder,Multicall,Context{

    address private erc1155WeaponsAddress;
    address private roleAddress;
    address private owner;
    address private signer;
    address private cyt;
    address private coin;
    bool _notEntered = true;
    uint256 public blockTimestampLast;
    
    error Unauthorized(address caller);

    event loadingRoleEvent(address from,uint256 tokenId);
    event loadingWeaponsEvent(address from,uint256 id,uint256 amount);

    event withdrawWeaponsEvent(address player,uint256[] ids,uint256[] amounts);
    event withdrawRoleEvent(address player,uint256 tokenId);

    event withdrawCytEVent(address player,uint256 amount,uint256 timeStamp);
    event withdrawCoinEvent(address player,uint256 amount,uint256 timeStamp);

    modifier nonReentrant() {
      require(_notEntered, "re-entered");
        _notEntered = false;
         _;
        _notEntered = true;
    }
   

    constructor(address signer_, address erc1155WeaponsAddress_, address roleAddress_, address cyt_, address coin_){
     owner = _msgSender();
     signer = signer_;
     erc1155WeaponsAddress = erc1155WeaponsAddress_;
     roleAddress = roleAddress_;
     cyt = cyt_;
     coin = coin_;
   }
     
   /*
    * @dev:  Used by players to load the asset of erc721
    * @param: tokenId: The player wants to load the Id of the equipment
   */
    function loadingRole(uint256 tokenId)  external {
      IERC721(roleAddress).safeTransferFrom(_msgSender(),address(this),tokenId);
      emit loadingRoleEvent(_msgSender(),tokenId);
    }

   /*
    * @dev:  Used by players to load the asset of erc1155
    * @param: tokenId: The player wants to load the Id of the equipment. amout: the amount of erc1155
   */
    function loadingWeapons(
        uint256 id,
        uint256 amount) external {
      IERC1155(erc1155WeaponsAddress).safeTransferFrom(_msgSender(),address(this),id,amount,"");

      emit loadingWeaponsEvent(_msgSender(),id,amount);
    }

    /*@dev: player retrieve  cyt
     *@param: signature：proof of cyt. currentTimeStamp: timeStamp
    */ 
    function withdrawCyt(uint256 amount,bytes memory signature,uint256  currentTimeStamp)external nonReentrant {
      require(currentTimeStamp > blockTimestampLast,"the proof has expired");
      require(Proof.checkPermissions(signer,amount,signature,currentTimeStamp,"ERC20_CYT")==true,"You don't get the proof right");
      IERC20(cyt).transfer(_msgSender(),amount);
      blockTimestampLast = currentTimeStamp;
      emit withdrawCytEVent(_msgSender(),amount,currentTimeStamp);
    }

    /*@dev: player retrieve  coin
     *@param: signature：proof of cyt. currentTimeStamp: timeStamp
    */ 
    function withdrawCoin(uint256 amount,bytes memory signature,uint256 currentTimeStamp) external nonReentrant{
      require(currentTimeStamp > blockTimestampLast,"the proof has expired");
      require(Proof.checkPermissions(signer,amount,signature,currentTimeStamp,"ERC20_COIN")==true,"You don't get the proof right");
      IERC20(coin).transfer(_msgSender(),amount);
      blockTimestampLast = currentTimeStamp;
      emit withdrawCoinEvent(_msgSender(),amount,currentTimeStamp);
    }

   /* @dev:  player batch retrieves the asset of erc1155
    * @param: ids: the collection to retrieve the id . amounts: The number of ids to retrieve
    */
    function withdrawWeapons(address player,uint256[] memory ids,uint256[] memory amounts) external{
          if(msg.sender != owner){
              revert Unauthorized(msg.sender);
           }
       IERC1155(erc1155WeaponsAddress).safeBatchTransferFrom(address(this),owner,ids,amounts,"0x"); 
       emit withdrawWeaponsEvent(player,ids,amounts);
    }


    /*@dev: player retrieves the nft
    * @param: tokenId: The player wants to load the Id of the equipment. amout: the amount of erc721
    */
    function withdrawRole(address player,uint256 tokenId) external{
      if(msg.sender != owner){
              revert Unauthorized(msg.sender);
           }
      IERC721(roleAddress).safeTransferFrom(address(this),player,tokenId);
      emit withdrawRoleEvent(player,tokenId);     
    }

  
 
}