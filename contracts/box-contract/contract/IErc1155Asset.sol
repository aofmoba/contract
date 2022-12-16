// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IErc1155Asset{
    function burnBatch(address from,uint256[] memory ids,uint256[] memory amounts) external;
    function mintBatch(address to, uint256[] memory ids,uint256[] memory amounts,bytes memory data)external;
    function mint(address to,uint256 id,uint256 amount,bytes memory data)external;
    function burn(address account,uint256 id,uint256 value) external;
}