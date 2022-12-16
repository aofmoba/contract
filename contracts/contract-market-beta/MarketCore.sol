// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Proof.sol";
import "./MarketPojo.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MarketCore is MarketPojo{

    uint private offerFlag;   
    mapping(address => mapping(bytes32 => bool)) public orderState;
    bytes4 public constant SELECTOR = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
  
    address public feeTo;
    address public feeToSetter;

    constructor(address _feeToSetter){
        feeToSetter = _feeToSetter;
    }


    function hashOrder(Order memory order) internal pure returns(bytes memory){
        return abi.encode(order.maker,order.salt,order.listingTime,order.expirationTime,order.offer);
    }

   /* @dev: Validate the order parameters
   *  @param: dataA dataB: the encode of order
   */
    function orderParmeterValidation(bytes memory dataA,bytes memory dataB) internal view returns(uint offer){
         (address makerA,uint256 saltA,uint256 listingTimeA,uint256 expirationTimeA, bool offerA) = abi.decode(dataA, (address,uint256,uint,uint,bool));
         if(listingTimeA > block.timestamp || (expirationTimeA !=0 && expirationTimeA <= block.timestamp)){
             revert UnMatchTime(msg.sender,listingTimeA,expirationTimeA, block.timestamp);
         }

        (address makerB,uint256 saltB,uint256 listingTimeB,uint256 expirationTimeB,bool offerB) = abi.decode(dataB, (address,uint256,uint,uint,bool));
         if(listingTimeB > block.timestamp || (expirationTimeB !=0 && expirationTimeB <= block.timestamp)){
             revert UnMatchTime(msg.sender,listingTimeB,expirationTimeB, block.timestamp);
         }
         require(listingTimeA < listingTimeB,"Error sorting order");
         require(offerA != offerB,"Error order offer");
        return  (offerA==true ? 1:2);
    }


   /* @dev: Validate the order parameters
   *  @param: order struct 
   */
    function orderParmeterValidation(Order memory order) internal view returns(bool){
         if(order.listingTime > block.timestamp || (order.expirationTime !=0 && order.expirationTime <= block.timestamp)){
             revert UnMatchTime(msg.sender,order.listingTime,order.expirationTime, block.timestamp);
         }
        return true;
    }
    
   /* @dev: Validate the callData
   *  @param: firstCallData,secondCallData: callData parmeters
   */
    function callDataPrameterValidation(bytes memory firstCallData, bytes memory secondCallData) internal pure returns(bool) {
        address tokenA = Proof.bytesToAddress(Proof.getFirstAddress(firstCallData));
        address tokenB = Proof.bytesToAddress(Proof.getSecondAddress(firstCallData));
        address tokenC = Proof.bytesToAddress(Proof.getFirstAddress(secondCallData));
        address tokenD = Proof.bytesToAddress(Proof.getSecondAddress(secondCallData));
        require(tokenA == tokenD && tokenB == tokenC,"mistake callDatas");
        return true;
    }

    //compute fee 
    function Fee(uint256 number)internal pure returns(uint256){
        (bool flagA,uint256 numerator) = SafeMath.tryMul(number,25);
        uint256  denominator = 1000;
        require(flagA == true,"Numeric overflow");
        (bool flagB, uint256 result) = SafeMath.tryDiv(numerator,denominator);
        require(flagB==true,"Numeric overflow");
        require(result!=0," fee is zero error");
        return result;
    }

   /* @dev: execution callldata with  fee
   *  @param: firstCallData,secondCallData: callData parmeters
   */
    function calldataWithFee(bytes memory CallData) internal view returns(bytes memory callDataA,bytes memory callDataB){
        bytes memory data =   Proof.removeSelector(CallData);
        (address from,address to,uint256 value) = decodeCalldataErc20(data);
        uint256 valueA = Fee(value);
        (bool flag,uint256 valueB)  = SafeMath.trySub(value,valueA);
        require(flag==true,"error trySub");
        callDataA = abi.encodeWithSelector(SELECTOR,from,feeTo,valueA);  
        callDataB = abi.encodeWithSelector(SELECTOR,from,to,valueB);
        return(callDataA,callDataB);
    }
    
    function decodeCalldataErc20(bytes memory data) internal pure returns(address from,address to,uint256 value){
          (from,to,value) = abi.decode(data, (address,address,uint256));
          return (from,to,value);
    }

    function assetValidation(bytes memory data) internal view returns(bool) {
        (address tokenAddress,uint256 id,uint256 number) = abi.decode(data, (address,uint256,uint256));
        if(number == 0){
            return (IERC721(tokenAddress).ownerOf(id) == msg.sender);
        }else{
            return (IERC1155(tokenAddress).balanceOf(msg.sender,id) >= number);
        }
    }
    
   /* @dev: Submit  order
   *  @param: order: the struct of order. assetData: token asset address and number . orderData: treasure assets.
   */
    function commitOrder(  
        Order memory order,
        bytes memory assetData,  
        bytes memory callData, 
        bytes memory orderData,
        bytes calldata signature) internal {
        orderParmeterValidation(order);
        require(assetValidation(orderData) == true,"listing asset error");
        bytes memory  orderHash_ = hashOrder(order);
        (address target, uint256 value) = abi.decode(assetData,(address,uint256));        
        bytes32 orderHash = keccak256(orderHash_);
        bytes32 signatureHash = Proof.hashSignature(orderHash,Proof.getBehindBytes(callData),orderData,target);
        
        if(orderState[msg.sender][orderHash] == true){
              revert mistakeOrder(msg.sender,orderHash);
           }
        require(Proof.checkOrderPermissions(signatureHash,order.maker,signature) == true,"Please provide correct proof");
        orderState[msg.sender][orderHash] = true;
        emit commitOrderEvent(msg.sender,orderHash_,assetData,callData,orderData,signature,block.timestamp);
    }


   /* @dev: cancel  order
   *  @param: orderHash: the id of order
   */
    function cancelOrder_(bytes32 orderHash) internal {
        if(orderState[msg.sender][orderHash] == false){
              revert mistakeOrder(msg.sender,orderHash);
           }
           orderState[msg.sender][orderHash] = false;
        emit cancelOrderEvent(msg.sender,orderHash,block.timestamp);
    }

    function transferWithFee(uint offer,address firstcallTarget, address secondCallTarget,bytes memory firstCallData, bytes memory secondCallData) internal  {
       (bytes memory callDataA,bytes memory callDataB) = (offer==1 ? calldataWithFee(firstCallData): calldataWithFee(secondCallData));
        address tokenAAddress = (offer==1 ? firstcallTarget:secondCallTarget);

        bytes memory callDataC = (offer == 1 ? secondCallData:firstCallData);
        address tokenBAddress= (offer==1 ? secondCallTarget:firstcallTarget);
        executeCall(tokenAAddress,callDataA);
        executeCall(tokenAAddress,callDataB);
        executeCall(tokenBAddress,callDataC);        

    }
    
   /* @dev: mathc order
   *  @param: hashorders: the order collection: singers: accounts address. callTarget：tokenaddress of asset
   */
    function orderMatch_(bytes memory hashOrders,bytes memory singers, bytes memory callDatas,bytes memory callTarget, bytes memory signatures,bytes memory orderData)  internal{
            
        (address firstsinger, address secondsinger) = abi.decode(singers,(address,address));
        (address firstcallTarget, address secondCallTarget) = abi.decode(callTarget,(address,address));
        (bytes memory firstSignature, bytes memory secondSignature) = abi.decode(signatures, (bytes, bytes));
        (bytes memory firstOrderHash_, bytes  memory secondOrderHash_) = abi.decode(hashOrders, (bytes, bytes));  
        (bytes memory firstCallData, bytes memory secondCallData) = abi.decode(callDatas, (bytes, bytes));
         
        offerFlag = orderParmeterValidation(firstOrderHash_,secondOrderHash_);
        bytes32 firstSignatureHash = Proof.hashSignature(keccak256(firstOrderHash_),Proof.getBehindBytes(secondCallData),orderData,secondCallTarget);
        bytes32 seccondSignatureHash = Proof.hashSignature( keccak256(secondOrderHash_),Proof.getBehindBytes(firstCallData),orderData,firstcallTarget);
            
        require(orderState[firstsinger][keccak256(firstOrderHash_)]==true,"order status incorrect ");
        require( Proof.checkOrderPermissions(firstSignatureHash,firstsinger,firstSignature) == true, "Please provide correct proof" );    
        require( Proof.checkOrderPermissions(seccondSignatureHash,secondsinger,secondSignature) == true, "Please provide correct proof" );            
        
        orderState[firstsinger][keccak256(firstOrderHash_)]=false;
        callDataPrameterValidation(firstCallData,secondCallData);
        transferWithFee(offerFlag,firstcallTarget,secondCallTarget,firstCallData,secondCallData);
        emit orderMatchEvent(firstsinger,secondsinger,keccak256(firstOrderHash_),keccak256(secondOrderHash_),block.timestamp);
    }

    function executeCall(address callTarget, bytes memory callData) internal {
        (bool success, bytes memory data) = callTarget.call(callData);
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'cyberpop: TRANSFER_FAILED'); 
    }

}
