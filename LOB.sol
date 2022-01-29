pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LOB is ERC20 {
    constructor(uint256 initialSupply) ERC20("LOBTOken", "LOB") {
        mint(initialSupply);
    }

    function mint(uint256 initialSupply) public{
      _mint(msg.sender, initialSupply);
    }

}