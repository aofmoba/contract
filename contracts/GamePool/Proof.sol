// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import  "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

library Proof{

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

  
   function strConcat(string memory str1, string memory str2,string memory str3,string memory str4,string memory str5) internal pure returns (string memory){
        bytes memory _str1 = bytes(str1);
        bytes memory _str2 = bytes(str2);
        bytes memory _str3 = bytes(str3);
        bytes memory _str4 = bytes(str4);
        bytes memory _str5 = bytes(str5);
        string memory ret = new string(_str1.length + _str2.length + _str3.length + _str4.length+ _str5.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _str1.length; i++)bret[k++] = _str1[i];
        for (uint i = 0; i < _str2.length; i++) bret[k++] = _str2[i];
        for (uint i = 0; i < _str3.length; i++) bret[k++] = _str3[i];
        for (uint i = 0; i < _str4.length; i++) bret[k++] = _str4[i];
        for (uint i = 0; i < _str5.length; i++) bret[k++] = _str5[i];
        return string(ret);
   }  

   function strConcat(string memory str1, string memory str2,string memory str3,string memory str4,string memory str5,string memory str6) internal pure returns (string memory){
        bytes memory _str1 = bytes(str1);
        bytes memory _str2 = bytes(str2);
        bytes memory _str3 = bytes(str3);
        bytes memory _str4 = bytes(str4);
        bytes memory _str5 = bytes(str5);
        bytes memory _str6 = bytes(str6);
        string memory ret = new string(_str1.length + _str2.length + _str3.length + _str4.length+ _str5.length + _str6.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _str1.length; i++)bret[k++] = _str1[i];
        for (uint i = 0; i < _str2.length; i++) bret[k++] = _str2[i];
        for (uint i = 0; i < _str3.length; i++) bret[k++] = _str3[i];
        for (uint i = 0; i < _str4.length; i++) bret[k++] = _str4[i];
        for (uint i = 0; i < _str5.length; i++) bret[k++] = _str5[i];
        for (uint i = 0; i < _str6.length; i++) bret[k++] = _str6[i];
        return string(ret);
   }  

   function strConcat(string memory str1, string memory str2,string memory str3,string memory str4,string memory str5,string memory str6,string memory str7,string memory str8) internal pure returns (string memory){
        bytes memory _str1 = bytes(str1);
        bytes memory _str2 = bytes(str2);
        bytes memory _str3 = bytes(str3);
        bytes memory _str4 = bytes(str4);
        bytes memory _str5 = bytes(str5);
        bytes memory _str6 = bytes(str6);
        bytes memory _str7 = bytes(str7);
        bytes memory _str8 = bytes(str8);
        string memory ret = new string(_str1.length + _str2.length + _str3.length + _str4.length+ _str5.length + _str6.length+ _str7.length + _str8.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _str1.length; i++)bret[k++] = _str1[i];
        for (uint i = 0; i < _str2.length; i++) bret[k++] = _str2[i];
        for (uint i = 0; i < _str3.length; i++) bret[k++] = _str3[i];
        for (uint i = 0; i < _str4.length; i++) bret[k++] = _str4[i];
        for (uint i = 0; i < _str5.length; i++) bret[k++] = _str5[i];
        for (uint i = 0; i < _str6.length; i++) bret[k++] = _str6[i];
        for (uint i = 0; i < _str7.length; i++) bret[k++] = _str7[i];
        for (uint i = 0; i < _str8.length; i++) bret[k++] = _str8[i];
        return string(ret);
   }  

  //Convert parameter types from address to string
    function addrToStr(address account) internal pure returns (string memory) {
      return bytesToStr(abi.encodePacked(account));
   }

    function getHash(address from,string memory newId,string memory timestamp,string memory tokenName,string memory chainId) internal pure returns (bytes32 result){  
        return ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(strConcat(addrToStr(from),newId,timestamp,tokenName,chainId))));
     }  

     function getHash(address from,string memory newId, string memory amount, string memory timestamp,string memory tokenName,string memory chainId) internal pure returns (bytes32 result){  
        return ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(strConcat(addrToStr(from),newId,amount,timestamp,tokenName,chainId))));
     }  

     function getHash(string memory id ,string memory value,address from,string memory newId,string memory amount,address tokenAddress,string memory currentTimeStamp,string memory chainId) internal pure returns (bytes32 result){  
        return ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(strConcat(id,value,addrToStr(from),newId,amount,addrToStr(tokenAddress),currentTimeStamp,chainId))));
     }  


   /* @dev: Check the correctness of the proof
   *  @param: newId: the id of bd. signature: The signature of the server. timestamp: The timestamp at the time the proof was generated
   */
    function checkPermissions(address signer,uint256 salt, bytes memory signature,uint256 timestamp,string memory tokenName,uint chainId) internal view returns(bool) {
        return SignatureChecker.isValidSignatureNow(signer,getHash(msg.sender,Strings.toString(salt),Strings.toString(timestamp),tokenName,Strings.toString(chainId)),signature);
    }


   /* @dev: Check the correctness of the proof
   *  @param: newId: the id of bd. signature: The signature of the server. timestamp: The timestamp at the time the proof was generated
   */
    function checkPermissions(address signer,uint256 id,uint256 amount, bytes memory signature,uint256 timestamp,string memory tokenName,uint chainId) internal view returns(bool) {
        return SignatureChecker.isValidSignatureNow(signer,getHash(msg.sender,Strings.toString(id),Strings.toString(amount),Strings.toString(timestamp),tokenName,Strings.toString(chainId)),signature);
    }


    function checkPermissions(uint256 id, uint256 value, uint256 newId, uint256 amount,address tokenAddress,uint256  timestamp,uint256 chainId,address signer,bytes memory signature) internal view returns(bool) {
        return SignatureChecker.isValidSignatureNow(signer,getHash(Strings.toString(id),Strings.toString(value),msg.sender,Strings.toString(newId),Strings.toString(amount),tokenAddress,Strings.toString(timestamp),Strings.toString(chainId)),signature);
    }

}