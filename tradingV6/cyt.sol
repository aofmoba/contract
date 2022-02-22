// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IMarket.sol";
contract market is IMarket {
    
    address public usdt;
    address public cyt;
    address public gamePropeAddress;
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
        require(balancePropeCreators[tokenId][msg.sender] <= IERC1155(gamePropeAddress).balanceOf(account,tokenId),"Insufficient balance of your prope");
    }

    event purchaseGoodsEvent(address from,address to,uint256 tokenId,uint256 amount,uint256 price);
    //可以通过事件查询宝物也可通过合约的方式
    event sellPropeEvent(address account,uint256 price,uint256 tokenId,uint256 amount,string  tokenUrl);    
   
   constructor(address usdt_,address cyt_,address gamePropeAddress_) {
         cyt = cyt_;
         usdt = usdt_;
         gamePropeAddress = gamePropeAddress_;
   }


    using SafeMath for uint256;

    function checkTokenId(uint256 tokenId)private view returns(bool) {
       bool  hasTokenId;
       for(uint i = 0;i <tokenIds.length;i++){
         hasTokenId =  tokenId == tokenIds[i] ? true : false;
       }
       return hasTokenId;
    }


    function setUsdtAddress(address usdt_) external {
          usdt = usdt_;
    }

    
    function setCytAddress(address cyt_) external {
           cyt = cyt_;
    }

    function purchaseGoods(address from,address to,uint256 tokenId,uint256 price,uint256 amount)  external override nonReentrant{
        require(tokenId>=0,"tokenId: input value is not valid");
        require(tokenSupply[tokenId]>=0,"this prope is been sold");
        tokenSupply[tokenId] =  tokenSupply[tokenId] - amount; //? 
        balancePropeCreators[tokenId][from] = balancePropeCreators[tokenId][from] - amount;
        IERC20(cyt).transferFrom(to,from,price * amount);
        IERC1155(gamePropeAddress).safeTransferFrom(from,to,tokenId,amount,"0x"); //转账nft给玩家,  "0x"data数据后面再改出来
        require(tokenSupply[tokenId]>0,"There are not enough props on the market");
        emit purchaseGoodsEvent(from,to,tokenId,amount,price);
    }

    function purchaseGoodsWithUsdt(address from,address to,uint256 tokenId,uint256 price,uint256 amount)  external override nonReentrant{
        require(tokenId>=0,"tokenId: input value is not valid");
        require(tokenSupply[tokenId]>=0,"this prope is been sold");
        tokenSupply[tokenId] =  tokenSupply[tokenId] - amount; //? 
        balancePropeCreators[tokenId][from] = balancePropeCreators[tokenId][from] - amount;
        IERC20(usdt).transferFrom(to,from,price * amount);
        IERC1155(gamePropeAddress).safeTransferFrom(from,to,tokenId,amount,"0x"); //转账nft给玩家,  "0x"data数据后面再改出来
        require(tokenSupply[tokenId]>0,"There are not enough props on the market");
        emit purchaseGoodsEvent(from,to,tokenId,amount,price);
    }

    function sellPrope(uint256 price,uint256 tokenId,uint256 amount,string calldata tokenUrl) external override propeOwner(msg.sender,tokenId,amount){
        require(tokenId>=0||price>=0||amount>=0,"tokenId: input value is not valid"); 
        if(checkTokenId(tokenId)==false){
          tokenIds.push(tokenId);
        }
        balancePropeCreators[tokenId][msg.sender]  =  balancePropeCreators[tokenId][msg.sender] + amount;  //需要做安全处理
        tokenSupply[tokenId] = tokenSupply[tokenId] + amount; 
        emit sellPropeEvent(msg.sender,price,tokenId,amount,tokenUrl);
    }

}