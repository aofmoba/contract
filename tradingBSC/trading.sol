// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract trading is ERC1155Holder,ERC721Holder{
    address public usdt;
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

    constructor(address usdt_,address nft_){
        usdt = usdt_;
        nft = nft_;
        admin = msg.sender;
    }

    function mint(uint256 id) external{
        uint256 i;
        for(i = 0 ;i < ids.length;i++){
            if(id <= ids[i] ){
                break;
            }
        }
        IERC20(usdt).transferFrom(msg.sender,feeTo,prices[i]);
        IERC721(nft).transferFrom(address(this),msg.sender,id);
    }

    function setPrice(uint256 id,uint256 price_)external owner(msg.sender){
       uint256 idIndex = _idCounter.current();
        prices[idIndex] = price_;
        ids.push(id);
        _idCounter.increment();
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == admin, 'cyberpop: FORBIDDEN');
        feeTo = _feeTo;
    }

}