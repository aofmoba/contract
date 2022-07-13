// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BlindBox is ERC721, ERC721Enumerable, ERC721Burnable, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    uint256 public _optionId;
    string private _baseUri;

    constructor(uint256 optionId) ERC721("BlindBox", "BOX") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _baseUri = "https://api.cyberpop.online/gatebox";
        _optionId = optionId;
    }

    function burn(uint256 tokenId)
        public
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _burn(tokenId);
    }

    function name() public view override returns (string memory) {
        return
            string(abi.encodePacked(super.name(), Strings.toString(_optionId)));
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
    }

    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function setURI(string memory newuri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseUri = newuri;
    }

    function tokenURI(uint256) public view override returns (string memory) {
        return string(abi.encodePacked(_baseUri, Strings.toString(_optionId)));
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
