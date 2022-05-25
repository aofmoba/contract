// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CyberpopGame is ERC1155, AccessControl, ERC1155Supply {
    uint256 private _numOptions;
    address private _owner;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor() ERC1155("https://api.cyberpop.online/game/") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(BURNER_ROLE, _msgSender());
        _owner = _msgSender();
        _numOptions = 2;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function _setOwner() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _owner = _msgSender();
    }

    function name() public pure returns (string memory) {
        return "Cyberpop Game Item";
    }

    function symbol() public pure returns (string memory) {
        return "CBG";
    }

    function numOptions() public view returns (uint256) {
        return _numOptions;
    }

    function setNumOptions(uint256 options)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
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
        return string(abi.encodePacked(uri_prefix, Strings.toString(_tokenId)));
    }

    function setURI(string memory newuri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(newuri);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
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

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
