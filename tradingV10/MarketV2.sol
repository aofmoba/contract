// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";

contract MarketV2 is ERC1155Holder, ERC721Holder,Multicall{

    address public cyt;
    address public erc1155WeaponsAddress;
    address public nftAddress;
    address public lootBoxAddress;
    address private owner;

    bool _notEntered = true;
    
    mapping (uint256 => uint256) public tokenSupply;
    mapping (uint256 => uint256) public erc1155Price;   //盲盒id跟武器Id尽量不要重复  
    mapping (uint256 => uint256) public erc721Price;
    
   event buyNftEvent(address indexed  palyer,uint256 tokenId,uint256 price);
   event buyLootBoxEvent(address indexed palyer, uint256 tokenId,uint256 price,uint256 amount);
   event buyErc1155WeaponsEvent(address indexed palyer,uint256 tokenId,uint256 price,uint256 amount);

    error Unauthorized(address caller);
    error UnMatchPrice(address caller,uint256 id,uint256 price);

    modifier nonReentrant() {
      require(_notEntered, "re-entered");
        _notEntered = false;
         _;
        _notEntered = true;
   }

   constructor(address cyt_,address erc1155WeaponsAddress_,address nftAddress_,address lootBoxAddress_) {
         cyt = cyt_;
         erc1155WeaponsAddress = erc1155WeaponsAddress_;
         nftAddress = nftAddress_;
         lootBoxAddress = lootBoxAddress_;
         owner = msg.sender;
   }

    function sellNft(uint256 price,uint256 tokenId) external{
        if(msg.sender != owner){
              revert Unauthorized(msg.sender);
       }
     erc721Price[tokenId] = price;
     IERC721(nftAddress).safeTransferFrom(owner,address(this),tokenId);
    }

    function sellErc1155(address tokenAddress,uint256 price,uint256 tokenId,uint256 amount) external{
       if(msg.sender != owner){
              revert Unauthorized(msg.sender);
       } 
       erc1155Price[tokenId] = price;
       IERC1155(tokenAddress).safeTransferFrom(owner,address(this),tokenId,amount,"0x");
     }


    function withdrawNft(uint256 tokenId) external{
        if(msg.sender != owner){
              revert Unauthorized(msg.sender);
       }
       IERC721(nftAddress).safeTransferFrom(address(this),owner,tokenId); 
    }

    function withdrawErc1155(address tokenAddress, uint256[] memory ids,uint256[] memory amounts) external {
        if(msg.sender != owner){
              revert Unauthorized(msg.sender);
       } 
       IERC1155(tokenAddress).safeBatchTransferFrom(address(this),owner,ids,amounts,"0x"); 
    }

    function buyNft(uint256 tokenId,uint256 price) external nonReentrant{
      if(price != erc721Price[tokenId]){
         revert UnMatchPrice(msg.sender,tokenId,price);
      }
      IERC20(cyt).transferFrom(msg.sender,owner,price);
      IERC721(nftAddress).safeTransferFrom(address(this),msg.sender,tokenId);
      emit buyNftEvent(msg.sender,tokenId,price);
    }

    function buyNftWithPermit(uint256 tokenId,uint256 price,uint256 deadline, uint8 v, bytes32 r, bytes32 s) external nonReentrant{
      if(price != erc721Price[tokenId]){
         revert UnMatchPrice(msg.sender,tokenId,price);
      }
      IERC20Permit(cyt).permit(msg.sender,address(this),price,deadline,v,r,s);
      IERC20(cyt).transferFrom(msg.sender,owner,price);
      IERC721(nftAddress).safeTransferFrom(address(this),msg.sender,tokenId);
      emit buyNftEvent(msg.sender,tokenId,price);
    }

    function buyErc1155Weapons(uint256 tokenId,uint256 price,uint256 amount) external{
      if(price != erc1155Price[tokenId]){
         revert UnMatchPrice(msg.sender,tokenId,price);
      }
      IERC20(cyt).transferFrom(msg.sender,owner,price * amount);
      IERC1155(erc1155WeaponsAddress).safeTransferFrom(address(this),msg.sender,tokenId,amount,"0x");
      emit buyErc1155WeaponsEvent(msg.sender,tokenId,price*amount,amount);
    }


    function buyErc1155WeaponsWithPermit(uint256 tokenId,uint256 price,uint256 amount,uint256 deadline, uint8 v, bytes32 r, bytes32 s) external nonReentrant{
      if(price != erc1155Price[tokenId]){
         revert UnMatchPrice(msg.sender,tokenId,price);
      }
      IERC20Permit(cyt).permit(msg.sender,address(this),price,deadline,v,r,s);
      IERC20(cyt).transferFrom(msg.sender,owner,price * amount);
      IERC1155(erc1155WeaponsAddress).safeTransferFrom(address(this),msg.sender,tokenId,amount,"0x");
      emit buyErc1155WeaponsEvent(msg.sender,tokenId,price*amount,amount);
    }

    function buyLootBoxWeapons(uint256 tokenId,uint256 price,uint256 amount) external {
       if(price != erc1155Price[tokenId]){
         revert UnMatchPrice(msg.sender,tokenId,price);
      }
      IERC20(cyt).transferFrom(msg.sender,owner,price * amount);
      IERC1155(lootBoxAddress).safeTransferFrom(address(this),msg.sender,tokenId,amount,"0x");
      emit buyLootBoxEvent(msg.sender,tokenId,price,amount);
    }

    
    function buyLootBoxWeaponsWithPermit(uint256 tokenId,uint256 price,uint256 amount) external {
       if(price != erc1155Price[tokenId]){
         revert UnMatchPrice(msg.sender,tokenId,price);
      }
      IERC20(cyt).transferFrom(msg.sender,owner,price * amount);
      IERC1155(lootBoxAddress).safeTransferFrom(address(this),msg.sender,tokenId,amount,"0x");
      emit buyLootBoxEvent(msg.sender,tokenId,price,amount);
    }


    function modifyErc1155Price(uint256 id,uint256 price) external{
       if(msg.sender != owner){
              revert Unauthorized(msg.sender);
       } 
       erc1155Price[id] = price;
    }

    function modifyErc721Price(uint256 id,uint256 price) external{
       if(msg.sender != owner){
              revert Unauthorized(msg.sender);
       } 
      erc721Price[id] = price;
    }

}