// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


contract MerkleProofWrapper {
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) public pure returns (bool) {
        return MerkleProof.verify(proof, root, leaf);
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) public pure returns (bytes32) {
        return MerkleProof.processProof(proof, leaf);
    }
}