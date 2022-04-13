// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20VotesComp.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract CyberPopToken is
    ERC20,
    Pausable,
    ERC20Permit,
    ERC20VotesComp,
    AccessControl
{
    using Address for address;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public CAP = 120 * 10e12 * 10**decimals();

    constructor() ERC20("CyberPopToken", "CYT") ERC20Permit("CyberPopToken") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);

        _mint(msg.sender, CAP); // capped at 120m
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function _contractTransferCallback(
        address _from,
        address _to,
        uint256 _value,
        bytes memory _data
    ) internal returns (bool) {
        string memory signature = "onTokenTransfer(address,uint256,bytes)";
        (bool success, ) = _to.call(
            abi.encodeWithSignature(signature, _from, _value, _data)
        );
        return success;
    }

    function mint(address to, uint256 amount)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
        if (to.isContract()) {
            _contractTransferCallback(from, to, amount, new bytes(0));
        }
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        require(totalSupply() <= CAP, "CYT: capped");
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}
