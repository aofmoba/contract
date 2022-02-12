// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IGameItem.sol";
import "./IMarket.sol";
contract market is IMarket {
    
    address private usdt;
    address private gamePropeAddress;
    bool _notEntered = true;
    
    mapping (uint256 => uint256) public tokenSupply;
    mapping (uint256 => mapping(address => uint256)) public balancePropeCreators;
    
    uint256[] private tokenIds;  //用来显示玩家已经出售在市场上面的宝物

 //防止重入攻击
    modifier nonReentrant() {
      require(_notEntered, "re-entered");
        _notEntered = false;
         _;
        _notEntered = true;
   }


    modifier propeOwner(address account,uint256 tokenId,uint256 amount){
        require(IERC1155(gamePropeAddress).balanceOf(account,tokenId)>= amount,"Wrong amount");
        _;
    }

    event purchaseGoodsEvent(address from,address to,uint256 tokenId,uint256 price);
    //可以通过事件查询宝物也可通过合约的方式
    event sellPropeEvent(address account,uint256 price,uint256 tokenId,uint256 amount,string  tokenUrl);    
   constructor(address usdt_,address gamePropeAddress_) {
         usdt = usdt_;
         gamePropeAddress = gamePropeAddress_;
   }

    using SafeMath  for uint256;

    function checkTokenId(uint256 tokenId)private view returns(bool) {
       bool  hasTokenId;
       for(uint i = 0;i <tokenIds.length;i++){
         hasTokenId =  tokenId == tokenIds[i] ? true : false;
       }
       return hasTokenId;
    }

    //是否可以买多个
    function purchaseGoods(address from,address to,uint256 tokenId,uint256 price)  external override nonReentrant{
        require(tokenId>=0,"tokenId: input value is not valid");
        require(IGameItem(gamePropeAddress).showPropePrice(tokenId-1) == price,"Mismatch the price");
        require(tokenSupply[tokenId]>=0,"this prope is not been sold");
        tokenSupply[tokenId] =  tokenSupply[tokenId].sub(1); 
        balancePropeCreators[tokenId][from] = balancePropeCreators[tokenId][from].sub(1);
        IERC20(usdt).transferFrom(to,from,price);
        IERC1155(gamePropeAddress).safeTransferFrom(from,to,tokenId,1,"0x"); //转账nft给玩家,  "0x"data数据后面再改出来
        emit purchaseGoodsEvent(from,to,tokenId,price);
    }

    function sellPrope(address account,uint256 price,uint256 tokenId,uint256 amount,string calldata tokenUrl) external override propeOwner(account,tokenId,amount){
        require(tokenId>=0||price>=0||amount>=0,"tokenId: input value is not valid"); 
        if(checkTokenId(tokenId)==false){
          tokenIds.push(tokenId);
        }
        balancePropeCreators[tokenId][account]  =  balancePropeCreators[tokenId][account] + amount;  //需要做安全处理
        tokenSupply[tokenId] = tokenSupply[tokenId] + amount; 
        emit sellPropeEvent(account,price,tokenId,amount,tokenUrl);
    }

}