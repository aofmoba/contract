// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import  "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


library Proof {

  function bytesToAddress(bytes memory data)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(data, 20))
        }
    }

  function addressToBytes(address a) internal pure returns (bytes memory b) {
        assembly {
            let m := mload(0x40)
            a := and(a, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            mstore(
                add(m, 20),
                xor(0x140000000000000000000000000000000000000000, a)
            )
            mstore(0x40, add(m, 52))
            b := m
        }
  }



   function getFirstAddress(bytes memory callData) internal pure returns(bytes memory) {
    bytes memory result = new bytes(32);
    uint i = 0;
    uint j = 0;
    for(i=16; i<48 ;i++){
      result[j] = callData[i];
      j++;
    } 
    return result;
   }

   function getSecondAddress(bytes memory callData) internal pure returns(bytes memory){
    bytes memory result = new bytes(32);
    uint i = 0;
    uint j = 0;
    for(i=48; i<80 ;i++){
      result[j] = callData[i];
      j++;
    } 
    return result;
   }


  function removeSelector(bytes memory data) internal pure returns(bytes memory){
    bytes memory result = new bytes(data.length-4);
    uint i = 0;
    uint j = 0;
    for(i = 4 ; i<data.length;i++){
      result[j] = data[i];
      j++;
    }
    return result; 
  }


  function getBehindBytes(bytes memory data) internal pure returns(bytes memory){
    bytes memory result = new bytes(data.length-48);
    uint i = 0;
    uint j = 0;
    for(i = 48 ; i<data.length;i++){
      result[j] = data[i];
      j++;
    }
    return result; 
  }

  function bytes32ToString(bytes32 value) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            str[i*2] = alphabet[uint8(value[i] >> 4)];
            str[1+i*2] = alphabet[uint8(value[i] & 0x0f)];
        }
        return string(str);
    }

 //Convert parameter types from bytes to string
  function bytesToStr(bytes memory data) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
     }
      return string(str);
   }
  
   function strConcat(string memory str1, string memory str2,string memory str3,string memory str4)
    internal pure returns (string memory){
        bytes memory _str1 = bytes(str1);
        bytes memory _str2 = bytes(str2);
        bytes memory _str3 = bytes(str3);
        bytes memory _str4 = bytes(str4);
        string memory ret = new string(_str1.length + _str2.length + _str3.length + _str4.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _str1.length; i++)bret[k++] = _str1[i];
        for (uint i = 0; i < _str2.length; i++) bret[k++] = _str2[i];
        for (uint i = 0; i < _str3.length; i++) bret[k++] = _str3[i];
        for (uint i = 0; i < _str4.length; i++) bret[k++] = _str4[i];
        return string(ret);
   }  

  //Convert parameter types from address to string
    function addrToStr(address account) internal pure returns (string memory) {
        return bytesToStr(abi.encodePacked(account));
   }

     function checkOrderPermissions(bytes32 hash, address signer, bytes memory signature) internal view returns(bool){
         return SignatureChecker.isValidSignatureNow(signer,hash,signature);
    }

    
    function hashSignature(bytes32 hashOrder, bytes memory data, bytes memory orderData, address target) internal pure returns(bytes32){
      return  ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(Proof.strConcat(Proof.bytes32ToString(hashOrder), Proof.bytesToStr(data),Proof.bytesToStr(orderData), Proof.addrToStr(target)))));
    }
    
}