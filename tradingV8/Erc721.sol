// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "./Cyborg.sol";

contract MuticallTest{

    address  public  k ;

   function testReturnValues(GameItem cyborg,uint256[] memory ids)  external  {
        bytes[] memory calls = new bytes[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            calls[i] = abi.encodeWithSignature("ownerOf(uint256)", ids[i]);
        }
        bytes[] memory results = cyborg.multicall(calls);
        uint256 j = 0;
        k = abi.decode(results[j], (address));
   }

}