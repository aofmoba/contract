// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import "@openzeppelin/contracts/utils/Address.sol";

contract CyberpopToken is ERC20Permit("CyberpopToken"), ERC20Burnable, Pausable, AccessControl {
    using Address for address;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 public CAP = 120 * 1e9 * 10**decimals();

    constructor() ERC20("CyberpopToken", "CYT") {
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

    function transferAndCall(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        transfer(to, amount);
        if (to.isContract()) {
            require(
                _contractTransferCallback(msg.sender, to, amount, new bytes(0)),
                "You can't transfer to staking contract"
            );
        }
        return true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    
}