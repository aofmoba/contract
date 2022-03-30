// SPDX-License-Identifier: MIT

pragma solidity >0.4.9 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/** 
 * @notice Pseudo random number generator, any contract that need certain level of randomness can inherit
 *         from this contract
 */
abstract contract RNG {
    using SafeMath for uint256;
    uint256 private _seed;

    /// Allow changing the seed to increase difficulty of attacks
    function _setSeed(uint256 seed) internal {
        _seed = seed;
    }

    function _random() internal returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(blockhash(block.number - 1), msg.sender, _seed)
            )
        );
        _seed = randomNumber;
        return randomNumber;
    }
}
