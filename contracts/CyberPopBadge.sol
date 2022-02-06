// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

contract CyberPopBadge is
    Initializable,
    ERC1155Upgradeable,
    OwnableUpgradeable,
    ERC1155SupplyUpgradeable,
    UUPSUpgradeable
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() public initializer {
        __ERC1155_init("http://3.142.189.202:9001/server/");
        __Ownable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();
    }

    function name() public pure returns (string memory) {
        return "CyberPop Badge";
    }

    function symbol() public pure returns (string memory) {
        return "CBG";
    }

    function numOptions() public pure returns (uint256) {
        return 2;
    }

    function batchBalanceOf(address account)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory balances = new uint256[](numOptions());
        for (uint256 i = 0; i < numOptions(); i++) {
            balances[i] = balanceOf(account, i);
        }
        return balances;
    }

    function uri(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        string memory uri_prefix = super.uri(_tokenId);
        return
            string(
                abi.encodePacked(
                    uri_prefix,
                    StringsUpgradeable.toString(_tokenId)
                )
            );
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155Upgradeable, ERC1155SupplyUpgradeable) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
