// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract airdrop{

    address public coin;
    address public admin;
    address public feeTo;

    mapping(uint256 => mapping (address=>bool) ) public states;
    mapping(uint256 =>bytes32) public roots;
    

    event getRewardEvent(address account,uint256 peroid,uint256 amount);

    using Counters for Counters.Counter;
    Counters.Counter private _peroidCounter;

    modifier owner(address account) {
        require(admin == account,"cyberpop: FORBIDDEN");
        _;
    }

    constructor(address coin_){
       admin = msg.sender;
       coin = coin_;
       _peroidCounter.increment();
    }

    function getReward(uint256 n,uint256 amount,bytes32[] memory proof) external{
         bytes32 leaf = getLeaf(n,msg.sender,amount);
        require(states[n][msg.sender] == false,"Invalid number");
        require(verify(proof,roots[n],leaf) == true,"cyberpop: You don't get the proof right ");    
        states[n][msg.sender] = true;
        IERC20(coin).transfer(msg.sender,amount);
        emit getRewardEvent(msg.sender,n,amount);
    }


    function getLeaf(uint256 peroid,address account,uint256 amount) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(keccak256(abi.encodePacked(peroid,account,amount))));
    }
    
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) public  pure returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }

    function getLastPeroid() external view returns(uint256) {
        return _peroidCounter.current();
    }

    function setFeeTo(address _feeTo) external  owner(msg.sender){
        require(msg.sender == admin, 'cyberpop: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _admin) external  owner(msg.sender){
        require(msg.sender == _admin, 'cyberpop: FORBIDDEN');
        admin = _admin;
    }

    function setRoots(uint256 peroid,bytes32 root) external owner(msg.sender){
        roots[peroid] = root;
    }


}