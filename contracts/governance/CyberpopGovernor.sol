// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";

contract CyberpopGovernor is
    AccessControl,
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction
{
    string private _uriPrefix;

    constructor(IVotes _token)
        Governor("CyberpopGovernor")
        GovernorSettings(
            1, /* 1 block */
            45818, /* 1 week */
            4000e6
        )
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(20)
    {
        _uriPrefix = "https://api.cyberpop.online/proposal/";
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setVotingDelay(uint256 newVotingDelay)
        public
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setVotingDelay(newVotingDelay);
    }

    function setVotingPeriod(uint256 newVotingPeriod)
        public
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setVotingPeriod(newVotingPeriod);
    }

    function setProposalThreshold(uint256 newProposalThreshold)
        public
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _setProposalThreshold(newProposalThreshold);
    }

    function proposalURI(uint256 _proposalId)
        public
        view
        returns (string memory)
    {
        return
            string(abi.encodePacked(_uriPrefix, Strings.toString(_proposalId)));
    }

    function setURI(string memory newuri)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _uriPrefix = newuri;
    }

    // The following functions are overrides required by Solidity.

    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
