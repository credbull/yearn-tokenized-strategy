// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {BaseStrategy, ERC20} from "@tokenized-strategy/BaseStrategy.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";

import { console2 } from "forge-std/console2.sol";

/*
 *  This contract should be inherited and the three main abstract methods
 *  `_deployFunds`, `_freeFunds` and `_harvestAndReport` implemented to adapt
 *  the Strategy to the particular needs it has to generate yield. There are
 *  other optional methods that can be implemented to further customize
 *  the strategy if desired.
 */
contract ManualYieldStrategy is BaseStrategy, Context {
    using SafeERC20 for ERC20;

    uint256 public _borrowedAmount = 0;

    constructor(
        address _asset,
        string memory _name
    ) BaseStrategy(_asset, _name) {}

    /// @notice called during every deposit into your strategy to allow it to deploy the underlying asset deposited into the yield source.
    /// @dev - this will be a manual process in this strategy
    // solhint-disable-next-line no-empty-blocks
    function _deployFunds(uint256) internal override {}

    /// @notice called during withdraws from your strategy if there is not sufficient idle asset to service the full withdrawal.
    /// @dev - this will be a manual process in this strategy
    // solhint-disable-next-line no-empty-blocks
    function _freeFunds(uint256) internal override {}

    /// @notice repay loan back to the strategy (with or without yield)
    function repay(uint256 _tokenAmount) public onlyManagement {
        asset.safeTransferFrom(_msgSender(), address(this), _tokenAmount);

        // overpay the loan - e.g. including yield
        uint256 newBorrowedAmount = _tokenAmount >= _borrowedAmount ? 0 : _borrowedAmount - _tokenAmount;

        _updateBorrowedAmount(newBorrowedAmount);
    }

    /// @notice borrow from the strategy (to manually invest)
    function borrow(uint256 _tokenAmount) public onlyManagement {
        recoverERC20(address(asset), _tokenAmount);

        _updateBorrowedAmount(_borrowedAmount + _tokenAmount);
    }

    /// @notice borrow from the strategy (to manually invest)
    function _updateBorrowedAmount(uint256 _newBorrowedAmount) internal {
        uint256 prevBorrowedAmount = _borrowedAmount;

        _borrowedAmount = _newBorrowedAmount;

        // TODO - emit an event here
    }

    /**
     * @notice Sweep out tokens accidentally sent here.
     * @dev May only be called by management. If a pool has multiple tokens to sweep out, call this once for each.
     * @param _tokenAddress Address of token to sweep.
     * @param _tokenAmount Amount of tokens to sweep.
     */
    function recoverERC20(
        address _tokenAddress,
        uint256 _tokenAmount
    ) public onlyManagement {
        ERC20(_tokenAddress).safeTransfer(
            TokenizedStrategy.management(),
            _tokenAmount
        );
    }

    /// and return a full accounting of a trusted amount denominated in the underlying asset the strategy holds.
    // TODO - should we include the borrowed amount in totalAssets?  if not, the APY will be choppy deposit -> 0 -> deposit + yield -> 0 ...
    function _harvestAndReport()
        internal
        override
        returns (uint256 _totalAssets)
    {
        _totalAssets = asset.balanceOf(address(this)) + _borrowedAmount;
    }
}
