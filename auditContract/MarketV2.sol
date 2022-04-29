// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";

contract MarketV2 is ERC1155Holder, ERC721Holder,ERC1155,Multicall{

    address public cyt;
    address public erc1155Address;
    address public erc721Address;
    address private owner;

    bool _notEntered = true;
    
    mapping (uint256 => uint256) public tokenSupply;
    mapping (uint256 => mapping( address => uint256)) public priceMapping;
    mapping (address => mapping(uint256=>uint256)) public idMapping;
   
   using Counters for Counters.Counter;
   Counters.Counter private _counter;
   
   event buyErc721Event(address tokenAddress,address indexed  palyer,uint256 tokenId,uint256 price);
   event buyErc1155Event(address indexed palyer,uint256 tokenId,uint256 price,uint256 amount);

    error Unauthorized(address caller);
    error UnMatchPrice(address caller,uint256 id,uint256 price);

    modifier nonReentrant() {
      require(_notEntered, "re-entered");
        _notEntered = false;
         _;
        _notEntered = true;
   }

   constructor(address cyt_) {
         cyt = cyt_;
         owner = msg.sender();
   }

    /* @dev: official listings 
    * @param: price: Commodity prices. tokenId: id of the asset 
    */
    function sellNft(address tokenAddress,uint256 price,uint256 tokenId) external{
     require(IERC721(tokenAddress).ownerOf(tokenId) == msg.sender,"You are not the owner of the token");
     IERC721(tokenAddress).safeTransferFrom(msg.sender,address(this),tokenId);
     uint256 currentId  = _counter.current();
     _mint(msg.sender,currentId,1,"");
    _counter.increment();
     priceMapping(currentId,msg.sender,price);
    }


    /* @dev: official listings 
    * @param: price: Commodity prices. tokenId: the id of erc1155
    */
    function sellErc1155(address tokenAddress, uint256 price,uint256 tokenId,uint256 amount) external{
       require(IERC1155(tokenAddress).balanceOf(msg.sender,tokenId)>0,"Insufficient balance");
       IERC1155(tokenAddress).safeTransferFrom(msg.sender,address(this),tokenId,amount,"0x");
       uint256 currentId  = _counter.current();
       _mint(msg.sender,currentId,amount,"");
       _counter.increment();
       priceMapping(currentId,msg.sender,price);
    }

    //retrieve assets of erc721
    function withdrawNft(uint256 tokenId) external{
       IERC721(roleAddress).safeTransferFrom(address(this),msg.sender,tokenId); 
    }

    //retrieve assets of erc1155
    function withdrawErc1155(address tokenAddress, uint256[] memory ids,uint256[] memory amounts) external {
        if(msg.sender != owner){
              revert Unauthorized(msg.sender);
       } 
       IERC1155(tokenAddress).safeBatchTransferFrom(address(this),owner,ids,amounts,"0x"); 
    }

    /* @dev: Buy nft
    * @param: tokenId: The id number of the purchase. price: Corresponding price of id
    */
    function buyRole(uint256 tokenId,uint256 price) external nonReentrant{
      if(price != erc721Price[tokenId]){
         revert UnMatchPrice(msg.sender,tokenId,price);
      }
      IERC20(cyt).transferFrom(msg.sender,owner,price);
      IERC721(roleAddress).safeTransferFrom(address(this),msg.sender,tokenId);
      emit buyRoleEvent(msg.sender,tokenId,price);
    }

    // Purchase with signature
    function buyRoleWithPermit(uint256 tokenId,uint256 price,uint256 deadline, uint8 v, bytes32 r, bytes32 s) external nonReentrant{
      if(price != erc721Price[tokenId]){
         revert UnMatchPrice(msg.sender,tokenId,price);
      }
      IERC20Permit(cyt).permit(msg.sender,address(this),price,deadline,v,r,s);
      IERC20(cyt).transferFrom(msg.sender,owner,price);
      IERC721(roleAddress).safeTransferFrom(address(this),msg.sender,tokenId);
      emit buyRoleEvent(msg.sender,tokenId,price);
    }

    // purchase weapons
    function buyErc1155Weapons(uint256 tokenId,uint256 price,uint256 amount) external nonReentrant{
      if(price != erc1155Price[tokenId]){
         revert UnMatchPrice(msg.sender,tokenId,price);
      }
      IERC20(cyt).transferFrom(msg.sender,owner,price * amount);
      IERC1155(erc1155WeaponsAddress).safeTransferFrom(address(this),msg.sender,tokenId,amount,"0x");
      emit buyErc1155WeaponsEvent(msg.sender,tokenId,price*amount,amount);
    }

   // purchase weapons with signature
    function buyErc1155WeaponsWithPermit(uint256 tokenId,uint256 price,uint256 amount,uint256 deadline, uint8 v, bytes32 r, bytes32 s) external nonReentrant{
      if(price != erc1155Price[tokenId]){
         revert UnMatchPrice(msg.sender,tokenId,price);
      }
      IERC20Permit(cyt).permit(msg.sender,address(this),price,deadline,v,r,s);
      IERC20(cyt).transferFrom(msg.sender,owner,price * amount);
      IERC1155(erc1155WeaponsAddress).safeTransferFrom(address(this),msg.sender,tokenId,amount,"0x");
      emit buyErc1155WeaponsEvent(msg.sender,tokenId,price*amount,amount);
    }

   //purchase lootBox 
    function buyLootBox(uint256 tokenId,uint256 price,uint256 amount) external nonReentrant{
       if(price != erc1155Price[tokenId]){
         revert UnMatchPrice(msg.sender,tokenId,price);
      }
      IERC20(cyt).transferFrom(msg.sender,owner,price * amount);
      IERC1155(lootBoxAddress).safeTransferFrom(address(this),msg.sender,tokenId,amount,"0x");
      emit buyLootBoxEvent(msg.sender,tokenId,price,amount);
    }

   //purchase LootBoox with signature
    function buyLootBooxWithPermit(uint256 tokenId,uint256 price,uint256 amount,uint256 deadline, uint8 v, bytes32 r, bytes32 s) external nonReentrant{
       if(price != erc1155Price[tokenId]){
         revert UnMatchPrice(msg.sender,tokenId,price);
      }
      IERC20Permit(cyt).permit(msg.sender,address(this),price,deadline,v,r,s);
      IERC20(cyt).transferFrom(msg.sender,owner,price * amount);
      IERC1155(lootBoxAddress).safeTransferFrom(address(this),msg.sender,tokenId,amount,"0x");
      emit buyLootBoxEvent(msg.sender,tokenId,price,amount);
    }

   //modify the price of erc1155
    function modifyErc1155Price(uint256 id,uint256 price) external{
       if(msg.sender != owner){
              revert Unauthorized(msg.sender);
       } 
       erc1155Price[id] = price;
    }

   //modify the price of erc721
    function modifyErc721Price(uint256 id,uint256 price) external{
       if(msg.sender != owner){
              revert Unauthorized(msg.sender);
       } 
      erc721Price[id] = price;
    }
}