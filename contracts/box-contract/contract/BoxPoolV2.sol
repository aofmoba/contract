// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IErc1155Asset.sol";
import "./Counters.sol";

contract BoxPoolV2 is ERC1155Holder,ERC721Holder{

    address public usdt;
    address public admin;
    address public lootBox;
    address public feeTo;

    mapping(uint256 =>mapping (uint256 => uint256) ) public prices;
    mapping(uint256 =>bytes32) public roots;
    mapping(uint256 => bool) public randomNumStates;
    
    
    using Counters for Counters.Counter;
    Counters.Counter private _idCounter;
    Counters.Counter private _peroidCounter;

    event purchaseEvent(address account,uint256 peroid,uint256 price,uint256 randomNum,uint256 timestamp,uint256 boxId);
    event applyForEvent(address account,uint256 peroid,uint256 randomNum,uint256 timestamp,uint256 boxId);
    event getRewardEvent(address account,uint256 peroid,uint256 randomNum,uint256 timestamp,uint256 boxId);

    constructor(address admin_,address lootBox_,address usdt_,uint256 initId_){
       admin = admin_;
       lootBox = lootBox_;
       usdt = usdt_;
       _idCounter.setInitValue(initId_);
       _peroidCounter.increment();
    }

    modifier owner(address account) {
        require(admin == account,"cyberpop: FORBIDDEN");
        _;
    }

    function purchase(uint256 boxId) external{
        uint256 peroid = _peroidCounter.current();
        require(prices[peroid][boxId] != 0 ,"error boxId");
        IERC20(usdt).transferFrom(msg.sender,address(this),prices[peroid][boxId]);
        _idCounter.increment();
        emit purchaseEvent(msg.sender,peroid,prices[peroid][boxId],_idCounter.current(),block.timestamp,boxId);
    }

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }

    function getReward(uint256 boxId,address tokenAddress,uint256 n,uint256 randomNum,uint256 timestamp,bytes32[] memory proof) external{
        require(prices[n][boxId] != 0 ,"error boxId");   
        require(tokenAddress == lootBox,"Invalid address");
        bytes32 leaf = getLeaf(boxId,msg.sender,randomNum,tokenAddress,timestamp);
        require(randomNumStates[randomNum] == false,"Invalid number");
        require(verify(proof,roots[n],leaf) == true,"cyberpop: You don't get the proof right ");    
        randomNumStates[randomNum] = true;
        IErc1155Asset(lootBox).mint(msg.sender,boxId,1,"0x");
        emit getRewardEvent(msg.sender,n,randomNum,block.timestamp,boxId);
    }

    function applyFor(uint256 boxId,address tokenAddress,uint256 n,uint256 randomNum,uint256 timestamp,bytes32[] memory proof) external {
        require(tokenAddress == usdt,"Invalid address");
        require(prices[n][boxId] != 0 ,"error boxId");
        bytes32 leaf = getLeaf(boxId,msg.sender,randomNum,tokenAddress,timestamp);
        require(randomNumStates[randomNum] == false,"Invalid number");
        require(verify(proof,roots[n],leaf) == true,"cyberpop: You don't get the proof right ");    
        randomNumStates[randomNum] = true;
        (bool flag, uint256 amount) = SafeMath.trySub(prices[n][boxId],Fee(prices[n][boxId]));
        require(flag == true,"error trySub");
        IERC20(usdt).transfer(msg.sender,amount);
        emit applyForEvent(msg.sender,n,randomNum,block.timestamp,boxId);
    }

    //compute fee 
    function Fee(uint256 number)internal pure returns(uint256){
        (bool flagA,uint256 numerator) = SafeMath.tryMul(number,50);
        uint256  denominator = 1000;
        require(flagA == true,"Numeric overflow");
        (bool flagB, uint256 result) = SafeMath.tryDiv(numerator,denominator);
        require(flagB==true,"Numeric overflow");
        require(result!=0," fee is zero error");
        return result;
    }

    function getLeaf(uint256 boxId,address account,uint256 randomNum,address tokenAddress,uint256 timestamp) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(keccak256(abi.encodePacked(boxId,account,randomNum,tokenAddress,timestamp))));
    }

    function Lottery(bytes32 root) external owner(msg.sender){
        uint256 peroid = _peroidCounter.current();
        roots[peroid] = root;
        _peroidCounter.increment();
    
    } 

    function getLastPeroid() external view returns(uint256) {
        return _peroidCounter.current();
    }

    function setPrice(uint256 peroid,uint256 boxId,uint256 price) external owner(msg.sender){
            prices[peroid][boxId] = price;
    }

    function withdraw(uint256 amount) external owner(msg.sender){
        IERC20(usdt).transfer(msg.sender,amount);
    }

    function setFeeTo(address _feeTo) external  owner(msg.sender){
        require(msg.sender == admin, 'cyberpop: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _admin) external  owner(msg.sender){
        require(msg.sender == admin, 'cyberpop: FORBIDDEN');
        admin = _admin;
    }

}
