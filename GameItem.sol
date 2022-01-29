pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IGameItem.sol";

/*版本更新： 更新level为prcie
*           新增 purchaseGoods方法
*/ 
contract GameItems is ERC1155, IGameItem {

   //道具结构体
    struct gamePrope{
        uint256 gId;
        uint64 propeType;  //道具种类，支援卡,特殊招式等
        uint64 price;   // 更改：道具等级为道具价格
        string name;
        
    }

     modifier onlyOwner(){
        require( _msgSender() == owner,"sorry,No permissions");
        _;
    }

    gamePrope[] public gamePropeArray;
    address public owner;
    address public LOB;
    string  private URI_PREFIX = "https://cyberpop.mypinata.cloud/ipfs/";

   using Counters for Counters.Counter;
   Counters.Counter private _tokenIds;

  event createGamePropeEvent(address indexed  player,uint256 tokenId,string  name,uint64 propeType,uint64 price,string  tokenURI);
   
  event updateGamePropeEVent();

   constructor(address LOB_) ERC1155("https://cyberpop.mypinata.cloud/ipfs/{id}.json") {
         owner = _msgSender();
         LOB = LOB_;
   }
    
      //检查商品定价跟实际转账是否一致
    modifier checkGamesPrice(uint256 tokenId,uint256 amount){
        require(gamePropeArray[tokenId-1].price == amount,"The price of the item does not match");
        _;
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
    function totalSupply() view public returns(uint256 totalSupply){
        return _tokenIds.current();
    }

    /* 方法作用：创建单个宝物
     * 参数含义: 1) player：玩家钱包地址 2) name:道具名子 3） length 需要为玩家创建多少个nft 4) propeType 道具对应的类型（招式或者支援卡） 5) price:道具等级
     * 参数返回: tokendId: uint256
    */
      function createGamePrope(address player,string memory name,string memory tokenUrl,uint64 propeType,uint64 price)
        onlyOwner
        public
        returns (uint256 tokenId){
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
           gamePropeArray.push(gamePrope(newItemId,propeType,price,name));
          _mint(player, newItemId, 1, "");
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

     /* 方法作用：玩家购买商品
     * 参数含义: 1) tokenId：商品Id 2 price: 商品价格)
     * 操作方法： 需要from地址用户先调用setApprovalForAll授权给合约地址为ture
     * 参数返回: tokendId: uint256
    */

    //这个方法授权给msg.sender地址就可以购买了，所有得把这个方法抽象出来
    function purchaseGoods(address from,address to,uint256 tokenId,uint256 price) override checkGamesPrice(tokenId,price) public{
        require(tokenId>=0,"tokenId: input value is not valid");
        IERC20(LOB).transferFrom(to,from,price);
        // require(balanceOf(_msgSender(),tokenId)>=1,"The item has been sold, please contact the token of owner");
        safeTransferFrom(from,to,tokenId,1,"0x"); //转账nft给玩家
    }

    //该方法用于玩家内部交易

   //显示装备,该方法前期仅做测试用
   function showGamePropeInfo(uint gId) public view returns(gamePrope memory) {
        return gamePropeArray[gId];
    } 

}