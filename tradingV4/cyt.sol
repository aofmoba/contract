// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract cyt is ERC20 {
    constructor(uint256 initialSupply) ERC20("cyberpop", "cyt") {
        mint(initialSupply);
    }

    function mint(uint256 initialSupply) public{
      _mint(msg.sender, initialSupply);
    }

}