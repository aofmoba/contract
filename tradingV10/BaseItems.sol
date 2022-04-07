// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract BaseItem is Initializable,Multicall,ERC1155Holder,ERC721Holder{

    address private admin;
    address private erc1155AssetAddress;
    address private nftAddress;
    uint public last;
    mapping (uint256 => uint256) public nftMapping;

    constructor(address erc1155AssetAddress_,address nftAddress_){
        admin = msg.sender;
        erc1155AssetAddress = erc1155AssetAddress_;
        nftAddress = nftAddress_;
    }

    function setErc1155Adeeress(address erc1155AssetAddress_)public initializer{
        require(admin == msg.sender,"you do not own permission");
        erc1155AssetAddress = erc1155AssetAddress_;

    }

    function setNftMapping(uint256 tokenId,uint256 amount) public initializer{
        require(admin == msg.sender,"you do not own permission");
        nftMapping[tokenId] = amount;       
    }

    function getNft(address player,uint256 nftId,uint256 erc1155Id,bytes memory data) public{
        require(IERC1155(erc1155AssetAddress).balanceOf(msg.sender,erc1155Id) >= nftMapping[nftId],"Insufficient balance");
        nftMapping[nftId] = 9999999999999;
        IERC1155(erc1155AssetAddress).safeTransferFrom(player,address(this),nftMapping[nftId],data)    

    }

}