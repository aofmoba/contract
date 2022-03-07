// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./CyberPopToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TimeLock is Ownable {
    using SafeMath for uint256;
    address public token;
    uint256 public constant BATCH_PERIOD = 24 * 60 * 60 * 30;

    struct Locker {
        uint256 lockTimestamp;
        uint256 lockedAmount;
        uint256 releaseBatches;
        uint256 releasedAmount;
    }
    // Locked amount and release time for each address
    mapping(address => Locker) public lockedBalances;
    uint256 public totalLocked;

    event Withdraw(address user, uint256 amount);

    constructor(address _token) {
        token = _token;
    }

    /**
     * @dev Token owner can use this function to release their fund after the lock period
     */
    function withdraw() external {
        require(
            lockedBalances[msg.sender].lockTimestamp < block.timestamp,
            "CYT Locker: lock duration not passed"
        );
        uint256 _amount = releaseableAmount(msg.sender);
        require(_amount > 0, "CYT Locker: insufficient balance");

        subBalance(msg.sender, _amount);
        emit Withdraw(msg.sender, _amount);
        IERC20(token).transfer(msg.sender, _amount);
    }

    /**
     * @notice Mint Token to this contract, mark the owner and lock period
     * @dev Can only be called by owner
     */
    function lock(
        address _sender,
        uint256 _amount,
        uint256 _lockPeriod,
        uint256 _batches
    ) external onlyOwner {
        uint256 lockedAmount = lockedBalances[_sender].lockedAmount;
        require(
            lockedAmount == 0,
            "CYT Locker: cannot re-lock a locked address"
        );
        CyberPopToken(token).mint(address(this), _amount);
        lockedBalances[_sender].lockedAmount = _amount;
        lockedBalances[_sender].releaseBatches = _batches;
        lockedBalances[_sender].lockTimestamp = block.timestamp + _lockPeriod;
        totalLocked = totalLocked + _amount;
    }

    function subBalance(address _sender, uint256 _amount) private {
        lockedBalances[_sender].releasedAmount = lockedBalances[_sender]
            .releasedAmount
            .add(_amount);
        if (
            lockedBalances[_sender].lockedAmount <=
            lockedBalances[_sender].releasedAmount
        ) {
            delete lockedBalances[_sender]; // clean up storage for lockTimestamp
        }
        totalLocked = totalLocked - _amount;
    }

    function releaseableAmount(address _beneficient)
        public
        view
        returns (uint256)
    {
        uint256 _now = block.timestamp;
        Locker memory locker = lockedBalances[_beneficient];
        if (_now < locker.lockTimestamp) {
            return 0;
        }
        uint256 delta = _now.sub(lockedBalances[_beneficient].lockTimestamp);
        uint256 batches = delta.div(BATCH_PERIOD);
        if (batches > locker.releaseBatches) {
            return locker.lockedAmount - locker.releasedAmount;
        }
        return
            locker.lockedAmount *
            (batches / locker.releaseBatches) -
            locker.releasedAmount;
    }
}
