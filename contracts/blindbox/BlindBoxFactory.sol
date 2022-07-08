// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../utils/LootBoxRandomness.sol";
import "./BlindBox.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract BlindBoxFactory is AccessControl, ReentrancyGuard, Pausable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    address private _consumerableFactory;

    using LootBoxRandomness for LootBoxRandomness.LootBoxRandomnessState;
    LootBoxRandomness.LootBoxRandomnessState private state;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    mapping(uint256 => address) public _optionToBoxMapping;

    event OptionAdded(uint256 optionId, address boxAddress);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function name() public pure returns (string memory) {
        return "Cyberpop Blind Box Manager";
    }

    function symbol() public pure returns (string memory) {
        return "BLB";
    }

    ///////
    // MAIN FUNCTIONS
    //////

    /**
     * @dev User facing interface, use this function to get a random reward from the loot box
     */
    function unpack(address _boxAddress, uint256 _tokenId)
        external
        whenNotPaused
        nonReentrant
    {
        BlindBox box = BlindBox(_boxAddress);
        require(
            _msgSender() == box.ownerOf(_tokenId),
            "BlindBox unpack: tokenId owned by someone else"
        );
        box.burn(_tokenId);
        // Mint nfts contained by LootBox
        uint256 _optionId = box._optionId();
        LootBoxRandomness._mint(
            state,
            _optionId,
            _msgSender(),
            1,
            abi.encodePacked(_msgSender()),
            address(this)
        );
    }

    function grantMinter(address minterAddress)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        for (uint256 i = 0; i < numOptions(); i++) {
            BlindBox box = BlindBox(_optionToBoxMapping[i]);
            box.grantRole(MINTER_ROLE, minterAddress);
        }
    }

    function boxAddresses() public view returns (address[] memory) {
        address[] memory ret = new address[](numOptions());
        for (uint256 i = 0; i < numOptions(); i++) {
            ret[i] = _optionToBoxMapping[i];
        }
        return ret;
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function setState(uint256 _numOptions, uint256 _seed)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        LootBoxRandomness.initState(state, _numOptions, _seed);
    }

    function setFactoryForOption(uint256 _optionId, address _factoryAddress)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        LootBoxRandomness.setFactoryForOption(
            state,
            _optionId,
            _factoryAddress
        );
    }

    function setSeed(uint256 _seed) public onlyRole(DEFAULT_ADMIN_ROLE) {
        LootBoxRandomness.setSeed(state, _seed);
    }

    function addNewOption(
        address factoryAddress,
        uint16[] memory _probabilities
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 optionId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        BlindBox box = new BlindBox(optionId);
        box.grantRole(MINTER_ROLE, _msgSender());
        _optionToBoxMapping[optionId] = address(box);

        LootBoxRandomness.addNewOption(state, factoryAddress, _probabilities);
        emit OptionAdded(optionId, address(box));
    }

    /**
     * @notice Query current number of options
     */
    function numOptions() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    /**
     * @notice Query class probabilities for the given option
     */
    function classProbabilities(uint256 opitonId)
        external
        view
        returns (uint16[] memory)
    {
        return LootBoxRandomness.classProbabilities(state, opitonId);
    }

    /**
     * @notice Query factory address for the given option
     */
    function classFactoryAddress(uint256 optionId)
        external
        view
        returns (address)
    {
        return LootBoxRandomness.classFactoryAddress(state, optionId);
    }

    function batchBalanceOf(address account)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory balances = new uint256[](numOptions());
        for (uint256 i = 0; i < numOptions(); i++) {
            BlindBox box = BlindBox(_optionToBoxMapping[i]);
            balances[i] = box.balanceOf(account);
        }
        return balances;
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
}
