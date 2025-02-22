// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { IStrategyInterface } from "../../interfaces/IStrategyInterface.sol";
import { ManualYieldStrategy } from "../../spikes/ManualYieldStrategy.sol";
import { ITokenizedStrategy } from "@tokenized-strategy/interfaces/ITokenizedStrategy.sol";

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { Setup } from "../utils/Setup.sol";

contract ManualYieldStrategyTest is Setup {
    using SafeERC20 for ERC20;

    ITokenizedStrategy public tokenizedStrategy; // just wraps the strategy
    ManualYieldStrategy public manualStrategy;

    function setUp() public override {
        super.setUp();

        asset = ERC20(tokenAddrs["USDC"]);

        manualStrategy = new ManualYieldStrategy(address(asset), "ManualYieldStrategy 20250221");
        tokenizedStrategy = ITokenizedStrategy(address(manualStrategy));

        tokenizedStrategy.setKeeper(keeper);
        tokenizedStrategy.setPerformanceFeeRecipient(performanceFeeRecipient);
        tokenizedStrategy.setPendingManagement(management);
        // Accept management.
        vm.prank(management);
        tokenizedStrategy.acceptManagement();
    }

    function test__ManualYieldStrategy__Setup() public {
        assertEq(tokenizedStrategy.asset(), address(asset));
    }

    function test__ManualYieldStrategy___BorrowAndRepay() public {
        assertEq(asset.balanceOf(address(manualStrategy)), 0, "expected zero assets to start");

        // mint some deposits into strategy
        uint256 depositAmount = 1_000e18;
        mintAndDepositIntoStrategy(IStrategyInterface(address(manualStrategy)), user, depositAmount);
        assertEq(asset.balanceOf(address(manualStrategy)), depositAmount, "deposit failed");

        // ========================== borrow ==========================
        uint256 prevManagementBalance = asset.balanceOf(address(management));

        vm.prank(management);
        manualStrategy.borrow(depositAmount);

        assertEq(asset.balanceOf(management), prevManagementBalance + depositAmount, "manager should have borrowed all assets");
        assertEq(asset.balanceOf(address(manualStrategy)), 0, "strategy should have lent all assets");

        // ========================== partial repay ==========================
        uint256 repayAmount = 250e18;

        vm.startPrank(management);
        asset.approve(address(manualStrategy), repayAmount);
        manualStrategy.repay(repayAmount);
        vm.stopPrank();

        assertEq(asset.balanceOf(address(manualStrategy)), repayAmount, "replayAmount not returned to strategy");
    }

}
