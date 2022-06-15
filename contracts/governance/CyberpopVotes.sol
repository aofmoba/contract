// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract CyberpopVotes is AccessControl, ERC20Wrapper, ERC20Permit, ERC20Votes {
    constructor(IERC20 _underlyingToken)
        ERC20("CyberpopVotes", "vCYT")
        ERC20Wrapper(_underlyingToken)
        ERC20Permit("CyberpopVotes")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function recover(address account)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (uint256)
    {
        return _recover(account);
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}
