// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IErc1155Asset.sol";


contract Erc1155Asset is ERC1155,AccessControl,IErc1155Asset{
  

  string  private URI_PREFIX = "https://cyberpop.mypinata.cloud/ipfs/";

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  bytes32 public constant minterRole = keccak256("minterRole");
  bytes32 public constant burnerRole = keccak256("burnerRole");

   constructor() ERC1155("https://cyberpop.mypinata.cloud/ipfs/{id}.json") {

      _setupRole(DEFAULT_ADMIN_ROLE ,_msgSender());
      _setupRole(minterRole, _msgSender());
      _setupRole(burnerRole,_msgSender());
    
   }

    function uri(uint256 _tokenId) public override  view returns (string memory) {
        return string( abi.encodePacked(URI_PREFIX, Strings.toString(_tokenId), ".json" ));
    }

    function numOptions() view public returns(uint256 totalSupply){
        return _tokenIds.current();
    }

     function burnBatch(address from,uint256[] memory ids,uint256[] memory amounts) external override{
        require(hasRole(burnerRole, msg.sender), "Caller is not a burner");
        _burnBatch(from,ids,amounts);
    }

    function mint(address to,uint256 id,uint256 amount,bytes memory data) external override{
        require(hasRole(minterRole, msg.sender), "Caller is not a minter");
        _mint(to,id,amount,data);
    }

   function mintBatch(address to,uint256[] memory ids,uint256[] memory amounts,bytes memory data) external override{
       require(hasRole(minterRole, msg.sender), "Caller is not a minter");
       _mintBatch(to,ids,amounts,data);
   } 

   function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}