pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GameItems is ERC1155  {

   //道具结构体
    struct gamePrope{
        uint256 gId;
        uint64 propeType;  //道具种类，支援卡,特殊招式等
        uint64 level;   // 道具等级
        string name;
    }

     modifier onlyOwner(){
        require( _msgSender() == owner,"sorry,No permissions");
        _;
    }

    gamePrope[] public gamePropeArray;
    address public owner;
   string constant private URI_PREFIX = "https://assets.hbeasts.com/eggs/";

   using Counters for Counters.Counter;
   Counters.Counter private _tokenIds;

  event createGamePropeEvent(uint256 tokenId,address player,string  name,uint64 propeType,uint64 level);

   constructor() ERC1155("https://assets.hbeasts.com/eggs/{id}.json") {
         owner = _msgSender();
   }
    
    /*
    * 方法作用：显示对应token对应的urlength
    *  参数含义： _tokenId：对应的tokenId
    *   函数返回： 会返回对应道具的tokenUrl
    */
    function uri(uint256 _tokenId) public override  pure returns (string memory) {
        return string( abi.encodePacked(URI_PREFIX, Strings.toString(_tokenId), ".json" ));
    }


    /*
    *方法作用:返回总共发行的token种类数
    */
    function totalSupply() view public returns(uint256 totalSupply){
        return _tokenIds.current();
    }

    /* 方法作用：创建单个宝物
     * 参数含义: 1) player：玩家钱包地址 2) name:道具名子 3） length 需要为玩家创建多少个nft 4) propeType 道具对应的类型（招式或者支援卡） 5) level:道具等级
     * 参数返回: tokendId: uint256
    */
      function createGamePrope(address player,string memory name,uint64 propeType,uint64 level)
        onlyOwner
        public
        returns (uint256 tokenId){
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
           gamePropeArray.push(gamePrope(newItemId,propeType,level,name));
          _mint(player, newItemId, 1, "");
         emit createGamePropeEvent(newItemId,player,name,propeType,level);

    }


    /* 方法作用：批量创建多个nft宝物
     * 参数含义: 1) player：玩家钱包地址 2) name[]:道具名子 3） length 需要为玩家创建多少个nft 4) propeType[] 道具对应的类型（招式或者支援卡） 5) level:道具等级
     * 参数返回: tokendIds: uint256[]
    */
    function batchCreateGamePrope(address player,string[] memory name,uint64 length,uint64[] memory propeType,uint64[] memory level )
     public
     onlyOwner
     returns(uint256[] memory tokendIds) {

        require(length == propeType.length && name.length == propeType.length && propeType.length == level.length,"Array lengths do not match");
        uint256[] memory ids = new uint256[](length); 
        uint256[] memory amounts = new uint256[](length);
        for(uint i =0;i< length;i++){
          _tokenIds.increment();
          uint256 newItemId = _tokenIds.current();
          ids[i] = newItemId;
          amounts[i] = 1; //nft所以数量值为1
          gamePropeArray.push(gamePrope(newItemId,propeType[i],level[i],name[i]));
          emit createGamePropeEvent(newItemId,player,name[i],propeType[i],level[i]);
        }
      _mintBatch(player, ids, amounts, "");
        return ids;
    }


   //显示装备,该方法前期仅做测试用
   function showGamePropeInfo(uint gId) public view returns(gamePrope memory) {

        return gamePropeArray[gId];
    } 

}