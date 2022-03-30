// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./interfaces/IERC1155Factory.sol";
import "./CyberClub.sol";
import "./CyberPopBadge.sol";
import "./LootBox.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CyberClubFactory is Ownable, IERC1155Factory {
    CyberClub private char;
    // Russian doll lootbox
    LootBox private lootbox;
    CyberPopBadge private comsumerable;

    constructor(
        address _charAddress,
        address _lootboxAddress,
        address _comsumerableAddress
    ) {
        char = CyberClub(_charAddress);
        lootbox = LootBox(_lootboxAddress);
        comsumerable = CyberPopBadge(_comsumerableAddress);
    }

    function mint(
        uint256 _optionId,
        address _to,
        uint256,
        bytes memory _data
    ) public override onlyOwner {
        if (_optionId == 0) {
            char.safeMint(_to); // 头像
            return;
        }
        if (_optionId == 1) {
            lootbox.mint(_to, 0, 1, _data); // 头像盲盒
        }
        comsumerable.mint(_to, 0, 1, _data);
        comsumerable.mint(_to, 2, 5, _data);
    }
}
