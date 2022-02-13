// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IGameItem.sol";

/*版本更新： 更新level为prcie
*           新增 purchaseGoods方法
*           新增重入锁
*/ 

contract GameItems is ERC1155 ,IGameItem {

   //道具结构体
  struct gamePrope{
      uint256 gId;
      uint64 propeType;  //道具种类，支援卡,特殊招式等
      uint64 price;   // 更改：道具等级为道具价格
      string name;
        
    }

  gamePrope[] public gamePropeArray;
  address public owner;
  string  private URI_PREFIX = "https://cyberpop.mypinata.cloud/ipfs/";
  bool _notEntered = true;

   using Counters for Counters.Counter;
   Counters.Counter private _tokenIds;

  event createGamePropeEvent(address indexed  player,uint256 tokenId,string  name,uint64 propeType,uint64 price,string  tokenURI);
  event updateGamePropeEVent();

   constructor() ERC1155("https://cyberpop.mypinata.cloud/ipfs/{id}.json") {
         owner = _msgSender();
     
   }
    
     modifier onlyOwner(){
        require( _msgSender() == owner,"sorry,No permissions");
        _;
    }
    
        
    //防止重入攻击
    modifier nonReentrant() {
      require(_notEntered, "re-entered");
        _notEntered = false;
         _;
        _notEntered = true;
   }


    /*
    * 方法作用：显示对应token对应的urlength
    *  参数含义： _tokenId：对应的tokenId
    *   函数返回： 会返回对应道具的tokenUrl
    */
    function uri(uint256 _tokenId) public override  view returns (string memory) {
        return string( abi.encodePacked(URI_PREFIX, Strings.toString(_tokenId), ".json" ));
    }

    /*
    *方法作用:返回总共发行的tokenId
    */
    function numOptions() view public returns(uint256 totalSupply){
        return _tokenIds.current();
    }

    /* 方法作用：创建单个宝物
     * 参数含义: 1) player：玩家钱包地址 2) name:道具名子 3） length 需要为玩家创建多少个nft 4) propeType 道具对应的类型（招式或者支援卡） 5) price:道具等级
     * 参数返回: tokendId: uint256
    */
      function createGamePrope(address player,string memory name,string memory tokenUrl,uint64 propeType,uint64 price)
        onlyOwner
        public
        nonReentrant
        returns (uint256 tokenId){
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
           gamePropeArray.push(gamePrope(newItemId,propeType,price,name));
          _mint(player, newItemId, 2, "");
         emit createGamePropeEvent(player,newItemId,name,propeType,price,tokenUrl);
        return newItemId;
    }


    /* 方法作用：批量创建多个nft宝物
     * 参数含义: 1) player：玩家钱包地址 2) name[]:道具名子 3）tokensUrl:对应代币的url
     * 4) length 需要为玩家创建多少个nft 5) propeType[] 道具对应的类型（招式或者支援卡） 6) price:道具等级
     * 参数返回: tokendIds: uint256[]
    */
    function batchCreateGamePrope(address player,string[] memory name,string[] memory tokensUrl,uint64 length,uint64[] memory propeType,uint64[] memory price)
     public
     nonReentrant
     onlyOwner
     returns(uint256[] memory tokendIds) {

        require(length == tokensUrl.length  && propeType.length == tokensUrl.length && name.length == propeType.length && propeType.length == price.length,"Array lengths do not match");
        uint256[] memory ids = new uint256[](length); 
        uint256[] memory amounts = new uint256[](length);
        for(uint i =0;i< length;i++){
          _tokenIds.increment();
          uint256 newItemId = _tokenIds.current();
          ids[i] = newItemId;
          amounts[i] = 1; //nft所以数量值为1
          gamePropeArray.push(gamePrope(newItemId,propeType[i],price[i],name[i]));
          emit createGamePropeEvent(player,newItemId,name[i],propeType[i],price[i],tokensUrl[i]);
        }
      _mintBatch(player, ids, amounts, "");
        return ids;
    }

  function balanceOf_(address account, uint256 id) public view  override returns (uint256) {
        return super.balanceOf(account,id);
    }

  function safeTransferFrom_(address from,address to,uint256 id,uint256 amount, bytes memory data) external override {
       super.safeTransferFrom(from,to,id,amount,data);
  } 

  function showPropePrice(uint256 tokenId) external override view returns(uint256) {
    return gamePropeArray[tokenId-1].price;
  }

   //显示装备,该方法前期仅做测试用
   function showGamePropeInfo(uint gId) public view returns(gamePrope memory) {
        return gamePropeArray[gId];
    } 

}