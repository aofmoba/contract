// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IGameItem.sol";


contract GameItem is ERC1155,IGameItem,AccessControl{
  
  address public owner;
  string  private URI_PREFIX = "https://cyberpop.mypinata.cloud/ipfs/";
  bool _notEntered = true;

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  event createGamePropeEvent(address indexed  player,uint256 tokenId,uint256 amount,string tokenURI);

  bytes32 public constant minterRole = keccak256("minterRole");

   constructor() ERC1155("https://cyberpop.mypinata.cloud/ipfs/{id}.json") {
      owner = _msgSender();
      _setupRole(DEFAULT_ADMIN_ROLE ,_msgSender());
      _setupRole(minterRole, _msgSender());
    
   }
    
    //防止重入攻击
    modifier nonReentrant() {
      require(_notEntered, "re-entered");
        _notEntered = false;
         _;
        _notEntered = true;
   }

    function uri(uint256 _tokenId) public override  view returns (string memory) {
        return string( abi.encodePacked(URI_PREFIX, Strings.toString(_tokenId), ".json" ));
    }

    /*
    *方法作用:返回总共发行的tokenId种类
    */
    function numOptions() view public returns(uint256 totalSupply){
        return _tokenIds.current();
    }

 
    function createGamePrope(address player,string memory tokenUrl,uint256 tokenId,uint256 amount,bytes memory data)
        public
        nonReentrant
        returns (uint256){
        require(hasRole(minterRole, msg.sender), "Caller is not a minter");
        _tokenIds.increment();
        _mint(player, tokenId, amount, data);
         emit createGamePropeEvent(player,tokenId,amount,tokenUrl);
        return tokenId;
    }

 
    function batchCreateGamePrope(address player,string[] memory tokensUrl,uint256 [] memory tokenIds,uint256[] memory amounts,uint64 length,bytes memory data)
     public
     nonReentrant
     returns(uint256[] memory tokendIds) {
        require(length == tokensUrl.length && tokensUrl.length == tokenIds.length && tokenIds.length == amounts.length ,"Array lengths do not match");
        require(hasRole(minterRole, msg.sender), "Caller is not a minter");
        for(uint i =0;i< length;i++){
          _tokenIds.increment();
          emit createGamePropeEvent(player,tokenIds[i],amounts[i],tokensUrl[i]);
        }
      _mintBatch(player, tokenIds, amounts, data);
        return tokenIds;
    }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}