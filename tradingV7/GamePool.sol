// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract GamePool  is ERC1155Holder{

    address private erc1155AssetAddress;

    constructor(address erc1155AssetAddress_) {
     erc1155AssetAddress = erc1155AssetAddress_;
   }
   
    //
    function withdrawPrope(uint256 id) external{
    //IERC1155(erc1155AssetAddress).safeTransferFrom(address(this),);
    }
}