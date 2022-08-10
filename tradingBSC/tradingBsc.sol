// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "./IWBNB.sol";

contract tradingBsc is ERC1155Holder,ERC721Holder{
    
    address public nft;
    address public admin;
    address public WBNB; 
 
    mapping(uint256=>uint256) public price;
    mapping(uint256=>uint256[]) public ids;
     

    modifier owner(address account) {
        require(admin == account,"FORBIDDEN");
        _;
    }

   constructor(address nft_,address WBNB_){
        WBNB = WBNB_;
        nft = nft_;
        admin = msg.sender;
    }

    function mint(uint256 n) external payable{
        IWBNB(WBNB).deposit{value: price[n]}();
        IERC721(nft).transferFrom(address(this),msg.sender,ids[n][ids[n].length-1]);
        ids[n].pop();
    }

    function withdrawBNB(address feeTo,uint amountBNB) external  owner(msg.sender){      
        IWBNB(WBNB).withdraw(amountBNB);
        TransferHelper.safeTransferETH(feeTo, amountBNB);
    }

   function setPrice(uint256 n,uint256 price_)external owner(msg.sender){
        price[n] = price_;
    }

    function setIds(uint256 n,uint256[] memory ids_) external owner(msg.sender){
        for(uint256 i = 0; i < ids_.length ;i++){
            ids[n].push(ids_[i]);
        }
    }

   receive() external payable {
        assert(msg.sender == WBNB); // only accept bnb via fallback from the WBNB contract
    }


}