// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract GamePool  is ERC1155Holder, ERC721Holder{

    address private erc1155AssetAddress;
    address private nftAddress;
    mapping(uint256 => address) public _balances;

    constructor(address erc1155AssetAddress_, address nftAddress_) {
     erc1155AssetAddress = erc1155AssetAddress_;
     nftAddress = nftAddress_;
   }
   
    function loading(uint256 tokenId) public{
      _balances[tokenId] = msg.sender;
      IERC721(nftAddress).safeTransferFrom(msg.sender,address(this),tokenId);
      require(IERC721(nftAddress).ownerOf(tokenId) == address(this),"Please re-transfer");
    }

    function withdrawPrope(uint256 tokenId) external{
      require(_balances[tokenId] == msg.sender,"You don't have permissions");
      IERC721(nftAddress).safeTransferFrom(address(this),msg.sender,tokenId);
    }

}