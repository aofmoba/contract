// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";


contract GamePool  is ERC1155Holder, ERC721Holder,Multicall,Context{

    address private erc1155AssetAddress;
    address private nftAddress;
    address private owner;

    error Unauthorized(address caller);

    event loadingNftEvent(address from,uint256 tokenId);
    event loadingErc1155Event(address from,uint256 id,uint256 amount);

    event withdrawErc1155Event(address player,uint256[] ids,uint256[] amounts);
    event withdrawNftEvent(address player,uint256 tokenId);

    constructor(address erc1155AssetAddress_, address nftAddress_){
     owner = _msgSender();
     erc1155AssetAddress = erc1155AssetAddress_;
     nftAddress = nftAddress_;
   }
      
   /*
    * @dev:  Used by players to load the asset of erc721
    * @param: tokenId: The player wants to load the Id of the equipment
   */
    function loadingNft(uint256 tokenId)  external {
      IERC721(nftAddress).safeTransferFrom(_msgSender(),address(this),tokenId);
      require(IERC721(nftAddress).ownerOf(tokenId) == address(this),"Please re-transfer");
      emit loadingNftEvent(_msgSender(),tokenId);
    }


   /*
    * @dev:  Used by players to load the asset of erc1155
    * @param: tokenId: The player wants to load the Id of the equipment. amout: the amount of erc1155
   */
    function loadingErc1155(
        uint256 id,
        uint256 amount) external {
      IERC1155(erc1155AssetAddress).safeTransferFrom(_msgSender(),address(this),id,amount,"");
      emit loadingErc1155Event(_msgSender(),id,amount);
    }

   /* @dev:  player batch retrieves the asset of erc1155
    * @param: ids: the collection to retrieve the id . amounts: The number of ids to retrieve
    */
    function withdrawErc1155(address player,uint256[] memory ids,uint256[] memory amounts) external{
          if(msg.sender != owner){
              revert Unauthorized(msg.sender);
           }
       IERC1155(erc1155AssetAddress).safeBatchTransferFrom(address(this),owner,ids,amounts,"0x"); 
       emit withdrawErc1155Event(player,ids,amounts);
    }


    /* @dev: player retrieves the nft
    * @param: tokenId: The player wants to load the Id of the equipment. amout: the amount of erc721
    */
    function withdrawNft(address player,uint256 tokenId) external{
      if(msg.sender != owner){
              revert Unauthorized(msg.sender);
           }
      IERC721(nftAddress).safeTransferFrom(address(this),player,tokenId);
      emit withdrawNftEvent(player,tokenId);     
    }
}