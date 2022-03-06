// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

contract CyberPopBadge is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155SupplyUpgradeable,
    UUPSUpgradeable
{
    uint256 private _numOptions;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function __CyberPopBadge_init() private {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(BURNER_ROLE, _msgSender());
    }

    function initialize() public initializer {
        __ERC1155_init("https://api.cyberpop.online/badge/");
        __AccessControl_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();
        __CyberPopBadge_init();
        _numOptions = 2;
    }

    function name() public pure returns (string memory) {
        return "CyberPop Badge";
    }

    function symbol() public pure returns (string memory) {
        return "CBG";
    }

    function numOptions() public view returns (uint256) {
        return _numOptions;
    }

    function setNumOptions(uint256 options) public onlyOwner {
        _numOptions = options;
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
    ) public onlyMinter {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyMinter {
        _mintBatch(to, ids, amounts, data);
    }

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) public {
        require(
            account == _msgSender() ||
                isApprovedForAll(account, _msgSender()) ||
                hasRole(BURNER_ROLE, _msgSender()),
            "ERC1155: caller is not authorized to burn token"
        );

        _burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public {
        require(
            account == _msgSender() ||
                isApprovedForAll(account, _msgSender()) ||
                hasRole(BURNER_ROLE, _msgSender()),
            "ERC1155: caller is not authorized to burn token"
        );

        _burnBatch(account, ids, values);
    }



    /**
     * @dev Throws if called by any account other than the owner nor the minter.
     */
    modifier onlyMinter() {
        require(
            hasRole(MINTER_ROLE, _msgSender()) ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "CyberPopBadge: caller is not the owner nor the minter"
        );
        _;
    }

    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "CyberPopBadge: caller is not admin"
        );
        _;
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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
