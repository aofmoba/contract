// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./interfaces/IERC1155Factory.sol";
import "./CyberClub.sol";
import "./CyberpopGame.sol";
import "./LootBox.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

contract CyberClubFactory is AccessControl, IERC1155Factory, ERC1155Receiver {
    CyberClub private char;
    // Russian doll lootbox
    LootBox private lootbox;
    CyberpopGame private comsumerable;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address _charAddress, address _comsumerableAddress) {
        char = CyberClub(_charAddress);
        comsumerable = CyberpopGame(_comsumerableAddress);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function setCyberClub(address _address)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        char = CyberClub(_address);
    }

    function setLootBox(address _address)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        lootbox = LootBox(_address);
    }

    function setCyberpopGame(address _address)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        comsumerable = CyberpopGame(_address);
    }

    function mint(
        uint256 _optionId,
        address _to,
        uint256,
        bytes memory _data
    ) public override onlyRole(MINTER_ROLE) {
        if (_optionId == 0) {
            char.safeMint(_to); // 头像
            return;
        }
        if (_optionId == 1) {
            lootbox.mint(_to, 0, 1, _data); // 头像盲盒
        }
        uint256[] memory ids = new uint256[](2);
        ids[0] = 0;
        ids[1] = 2;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 1;
        amounts[1] = 5;
        // comsumerable.safeBatchTransferFrom(
        //     address(this),
        //     _to,
        //     ids,
        //     amounts,
        //     _data
        // );
        comsumerable.mintBatch(_to, ids, amounts, _data);
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl, ERC1155Receiver)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
