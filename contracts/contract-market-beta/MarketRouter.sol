// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./MarketCore.sol";

contract MarketRouter is MarketCore(msg.sender){

    bool isStopped = false;
    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'cyberpop: FORBIDDEN');
        feeTo = _feeTo;
    }

    modifier stoppedInEmergency {
        require(isStopped==false,"this contract enter a state of emergency");
        _;
    }


    function setIsStopped(bool switch_) external {
        require(msg.sender == feeToSetter, 'cyberpop: FORBIDDEN');
	isStopped = switch_;
    }


   /* @dev: Submit  order
   *  @param: maker:   accounts address  of order. listingTime: strat time of order. expirationTime:  expiratime of order. order: the struct of order. assetData: token asset address and number . orderData: treasure assets.
   */
    function commitOrder(  
        address maker, 
        uint256 salt,
        uint listingTime,
        uint expirationTime,
        bool offer,
        bytes memory assetData, 
        bytes memory callData, 
        bytes memory orderData,
        bytes calldata signature) external {
        MarketCore.commitOrder(Order(maker,salt,listingTime,expirationTime,offer),assetData,callData,orderData,signature);  
    }
    
   /* @dev: cancel  order
   *  @param: orderHash: the id of order
   */
    function cancelOrder(bytes32 orderHash)  external {
        MarketCore.cancelOrder_(orderHash);
    }

   /* @dev: mathc order
   *  @param: hashorders:  hashorders: the order collection: singers: accounts address. callTarget：tokenaddress of asset
   */
    function orderMatch(bytes memory hashOrders,bytes memory singers, bytes memory callDatas,bytes memory callTarget, bytes memory signatures,bytes memory orderData) external stoppedInEmergency {
        MarketCore.orderMatch_(hashOrders,singers,callDatas,callTarget,signatures,orderData);    
    }

}