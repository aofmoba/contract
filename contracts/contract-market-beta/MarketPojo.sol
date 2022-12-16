// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract MarketPojo{

    error Unauthorized(address caller);
    error UnMatchTime(address caller,uint256 listingTime,uint256 expirationTime,uint256 timestamp);
    error mistakeOrder(address caller, bytes32 orderHash);

    event commitOrderEvent(
        address callAddress,
        bytes orderHash,
        bytes assetData,
        bytes callData,
        bytes orderData,  
        bytes signature,
        uint256 timestamp);

    event cancelOrderEvent(
        address call,
        bytes32 orderHash,
        uint256 timestamp
    );

    event orderMatchEvent(
        address firstCaller,
        address seccondCaller,
        bytes32 firstHashOrder,
        bytes32 seccondHashOrder,
        uint256 timestamp
    );

    struct Order{
        address maker;  // order maker address
        uint256 salt;
        uint listingTime;
        uint expirationTime;
        bool offer;
    }
    
}