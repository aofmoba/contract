// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./CyberPopToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TimeLock is Ownable {
    address public token;

    struct Locker {
        uint256 lockTimestamp;
        uint256 lockedAmount;
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
    function withdraw(uint256 _amount) external {
        require(
            lockedBalances[msg.sender].lockTimestamp < block.timestamp,
            "CYT Locker: lock duration not passed"
        );
        require(
            lockedBalances[msg.sender].lockedAmount >= _amount,
            "CYT Locker: insufficient balance"
        );
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
        uint256 _dueTime
    ) external onlyOwner {
        uint256 lockedAmount = lockedBalances[_sender].lockedAmount;
        require(
            lockedAmount == 0,
            "CYT Locker: cannot re-lock a locked address"
        );
        CyberPopToken(token).mint(address(this), _amount);
        lockedBalances[_sender].lockedAmount = _amount;
        lockedBalances[_sender].lockTimestamp = _dueTime;
        totalLocked = totalLocked + _amount;
    }

    function subBalance(address _sender, uint256 _amount) private {
        lockedBalances[_sender].lockedAmount =
            lockedBalances[_sender].lockedAmount -
            _amount;
        if (lockedBalances[_sender].lockedAmount == 0) {
            delete lockedBalances[_sender]; // clean up storage for lockTimestamp
        }
        totalLocked = totalLocked - _amount;
    }
}
