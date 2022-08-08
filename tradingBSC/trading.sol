// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "./IWBNB.sol";

contract trading is ERC1155Holder,ERC721Holder{
    
    address public WBNB;
    address public nft;
    address public admin;
    address public feeTo;

    using Counters for Counters.Counter;
    Counters.Counter private _idCounter;

    mapping(uint256 => uint256) private prices;
    uint256[] public ids; 
    modifier owner(address account) {
        require(admin == account,"FORBIDDEN");
        _;
    }

    constructor(address nft_,address WBNB_){
        nft = nft_;
        WBNB = WBNB_;
        admin = msg.sender;
    }

    function mint(uint256 id) external payable{
        uint256 i;
        for(i = 0 ;i < ids.length;i++){
            if(id <= ids[i] ){
                break;
            }
        }
        IWBNB(WBNB).deposit{value: prices[i]}();
        IERC721(nft).transferFrom(address(this),msg.sender,id);
    }

    function withdrawBNB(address to,uint256 amountBNB) external owner(msg.sender){      
        IWBNB(WBNB).withdraw(amountBNB);
        TransferHelper.safeTransferETH(to, amountBNB);
}

    function setPrice(uint256 id,uint256 price_)external owner(msg.sender){
       uint256 idIndex = _idCounter.current();
        prices[idIndex] = price_ ;
        ids.push(id);
        _idCounter.increment();
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == admin, 'cyberpop: FORBIDDEN');
        feeTo = _feeTo;
    }


}