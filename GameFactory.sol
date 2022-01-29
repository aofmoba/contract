pragma solidity ^0.8.0;
import "./GameItem.sol";

contract GameFactory{
    address public feeToSetter;
    address[] public allpropeClass;

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    event createNewPropeEVent(string propeClassName,address propeClass,uint);

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function createNewPrope(string memory  propeClassName) public  payable returns (address propeClass){
        bytes memory bytecode = type(GameItems).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(propeClassName));     
        assembly {
            propeClass := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(propeClass != address(0), "Create2: Failed on deploy");
        allpropeClass.push(propeClass);
        emit createNewPropeEVent(propeClassName,propeClass,allpropeClass.length);
    }

    function createNewPrope2(address LOB,string memory  propeClassName) public  returns (address propeClass){
     
       return address(new GameItems{salt: keccak256(abi.encode(propeClass))}(LOB)); 
    }

}  