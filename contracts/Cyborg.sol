// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

contract Cyborg is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721BurnableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIdCounter;
    string private _uriPrefix;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function __Cyborg_init() private {
        _uriPrefix = "https://api.cyberpop.online/server/";
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function initialize() public initializer {
        __ERC721_init("Cyborg", "CYBER");
        __ERC721Enumerable_init();
        __ERC721Burnable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        __Cyborg_init();
    }

    function _baseURI() internal view override returns (string memory) {
        return _uriPrefix;
    }

    function setURI(string memory newuri) public onlyOwner {
        _uriPrefix = newuri;
    }

    /**
     * @dev Throws if called by any account other than the owner nor the minter.
     */
    modifier onlyMinter() {
        require(
            hasRole(MINTER_ROLE, _msgSender()) ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Cyborg: caller is not the owner nor the minter"
        );
        _;
    }

    modifier onlyOwner() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Cyborg: caller is not admin"
        );
        _;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(
                    _uriPrefix,
                    StringsUpgradeable.toString(_tokenId)
                )
            );
    }

    function safeMint(address to) public onlyMinter {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    // Allow specifying customized tokenId
    function safeMint(address to, uint256 tokenId) public onlyMinter {
        _safeMint(to, tokenId);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            AccessControlUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
