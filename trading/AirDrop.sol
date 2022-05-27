// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

//thih is a airDrop contract by Cyboerpop
contract AirDrop{

    address public  token;
    bytes32 public  merkleRoot;

    constructor(address token_, bytes32 merkleRoot_){
        token = token_;
        merkleRoot = merkleRoot_;
    }


    function distribute( address account, uint256 tokenId, bytes32[] calldata merkleProof) public   {
         bytes32 node =  keccak256(abi.encodePacked(keccak256(abi.encodePacked(account, tokenId))));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');
        IERC721(token).safeTransferFrom(address(this),account,tokenId);
    }


    function verify(
        bytes32[] memory proof,
        bytes32 root,
        address leaf_
    ) public pure returns (bool) {
        
        bytes32 hash = keccak256(abi.encodePacked(keccak256(abi.encodePacked(leaf_))));
        
        return MerkleProof.verify(proof, root, hash);
    }

    function getHash(address account, uint256 tokenId)public pure returns(bytes32 ){
        return keccak256(abi.encodePacked(account, tokenId));
    }

    function getHash2(address account, uint256 tokenId)public pure returns(bytes32 ){
         return keccak256(abi.encodePacked(keccak256(abi.encodePacked(account, tokenId))));
    }
 

    function processProof(bytes32[] memory proof, bytes32 leaf) public pure returns (bytes32) {
        return MerkleProof.processProof(proof, leaf);
    }
    
}