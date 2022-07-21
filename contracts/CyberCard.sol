// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract CyberCard is ERC721, ERC721Enumerable, Pausable, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    string private _uriPrefix;
    uint256 private _idPrefix;

    constructor(uint256 idPrefix) ERC721("Cyber Card", "CBCA") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _uriPrefix = "https://api.cyberpop.online/card/";
        _idPrefix = idPrefix * 10000;
    }

    function _baseURI() internal view override returns (string memory) {
        return _uriPrefix;
    }

    function setURI(string memory newuri)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _uriPrefix = newuri;
    }

    function setIdPrefix(uint256 prefix) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _idPrefix = prefix * 10000;
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, _idPrefix + tokenId);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return string(abi.encodePacked(_uriPrefix, Strings.toString(_tokenId)));
    }

    /**
     * @dev Returns all the token IDs owned by address
     */
    function tokensOfOwner(address _addr)
        external
        view
        returns (uint256[] memory)
    {
        uint256 balance = balanceOf(_addr);
        uint256[] memory tokens = new uint256[](balance);
        for (uint256 i = 0; i < balance; i++) {
            tokens[i] = tokenOfOwnerByIndex(_addr, i);
        }

        return tokens;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
