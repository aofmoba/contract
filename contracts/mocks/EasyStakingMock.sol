pragma solidity 0.8.9;

import "../EasyStaking.sol";

contract EasyStakingMock is EasyStaking {
    function fallback() external payable {}
}
