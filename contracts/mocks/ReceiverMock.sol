pragma solidity ^0.8.9;

contract ReceiverMock {
    fallback() external payable {
        revert("");
    }
}
