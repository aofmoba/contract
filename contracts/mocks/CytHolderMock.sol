contract CytHolderMock {
    function onTokenTransfer(
        address from,
        address to,
        uint256 amount,
        bytes memory data
    ) public returns (bool) {}
}
