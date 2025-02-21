// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {TokenizedStaker} from "@periphery/Bases/Staker/TokenizedStaker.sol";
import {ITokenizedStaker} from "@periphery/Bases/Staker/ITokenizedStaker.sol";

contract SimpleTokenizedStaker is TokenizedStaker {
    constructor(
        address _asset,
        string memory _name
    ) TokenizedStaker(_asset, _name) {}

    /// @dev called during every deposit into your strategy to allow it to deploy the underlying asset deposited into the yield source.
    function _deployFunds(uint256) internal override {

    }

    // @dev called during withdraws from your strategy if there is not sufficient idle asset to service the full withdrawal.
    function _freeFunds(uint256) internal override {

    }

    function _harvestAndReport()
        internal
        override
        returns (uint256 _totalAssets)
    {
        _totalAssets = asset.balanceOf(address(this));
    }
}
