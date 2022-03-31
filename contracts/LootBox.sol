// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./utils/LootBoxRandomness.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

contract LootBox is ERC1155, ERC1155Burnable, AccessControl {
    using LootBoxRandomness for LootBoxRandomness.LootBoxRandomnessState;
    LootBoxRandomness.LootBoxRandomnessState private state;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC1155("https://api.cyberpop.online/box/") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function setURI(string memory newuri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(newuri);
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

    ///////
    // MAIN FUNCTIONS
    //////

    /**
     * @dev User facing interface, use this function to get a random reward from the loot box
     */
    function unpack(uint256 _optionId, uint256 _amount) external {
        // This will underflow if _msgSender() does not own enough tokens.
        _burn(_msgSender(), _optionId, _amount);
        // Mint nfts contained by LootBox
        LootBoxRandomness._mint(
            state,
            _optionId,
            _msgSender(),
            _amount,
            "",
            address(this)
        );
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

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function setState(
        uint256 _numOptions,
        uint256 _numClasses,
        uint256 _seed
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        LootBoxRandomness.initState(state, _numOptions, _numClasses, _seed);
    }

    function setTokenIdsForClass(uint256 _classId, uint256[] memory _tokenIds)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        LootBoxRandomness.setTokenIdsForClass(state, _classId, _tokenIds);
    }

    function setFactoryForClass(uint256 _classId, address _factoryAddress)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        LootBoxRandomness.setFactoryForClass(state, _classId, _factoryAddress);
    }

    function setSeed(uint256 _seed) public onlyRole(DEFAULT_ADMIN_ROLE) {
        LootBoxRandomness.setSeed(state, _seed);
    }

    function setProbabilitiesForOption(
        uint256 _optionId,
        uint16[] memory _probabilities
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        LootBoxRandomness.setProbabilitiesForOption(
            state,
            _optionId,
            _probabilities
        );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
