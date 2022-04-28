pragma solidity 0.8.9;

contract ReceiverMock {
    function fallback() external payable {
        revert("");
    }
}
