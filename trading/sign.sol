// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import  "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract sign{
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

   function strConcat(string memory str1, string memory str2,string memory str3) internal pure returns (string memory){
        bytes memory _str1 = bytes(str1);
        bytes memory _str2 = bytes(str2);
        bytes memory _str3 = bytes(str3);
        string memory ret = new string(_str1.length + _str2.length + _str3.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        for (uint i = 0; i < _str1.length; i++)bret[k++] = _str1[i];
        for (uint i = 0; i < _str2.length; i++) bret[k++] = _str2[i];
        for (uint i = 0; i < _str3.length; i++) bret[k++] = _str3[i];
        return string(ret);
   }  

    function addrToStr(address account) internal pure returns (string memory) {
      return bytesToStr(abi.encodePacked(account));
   }

    function getHash(address from,string memory newId,string memory timestamp) internal pure returns (bytes32 result){  
        return  ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked( strConcat( addrToStr(from),newId,timestamp ))));
     }  

    function checkPermissions(address signer,uint256 newId, bytes memory signature,string memory timestamp) public view returns(bool) {
        return SignatureChecker.isValidSignatureNow(signer,getHash(msg.sender,Strings.toString(newId),timestamp),signature);
    }

}