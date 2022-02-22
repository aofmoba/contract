// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "./GameItem.sol";

contract GameFactory{
    address public feeToSetter;
    address[] public allpropeClass;

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    event createNewPropeEVent(string propeClassName,address propeClass,uint);

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function createNewPrope(address usdt,string memory propeClassName) public  returns (address propeClass){
       return address(new GameItems{salt: keccak256(abi.encode(propeClassName))}(usdt)); 
    }

}  