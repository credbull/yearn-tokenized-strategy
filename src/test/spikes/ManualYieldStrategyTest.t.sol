// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IStrategyInterface} from "../../interfaces/IStrategyInterface.sol";
import {ManualYieldStrategy} from "../../spikes/ManualYieldStrategy.sol";
import {ITokenizedStrategy} from "@tokenized-strategy/interfaces/ITokenizedStrategy.sol";
import {IBaseStrategy} from "@tokenized-strategy/interfaces/IBaseStrategy.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {Setup} from "../utils/Setup.sol";

contract ManualYieldStrategyTest is Setup {
    using SafeERC20 for ERC20;

    ITokenizedStrategy public tokenizedStrategy; // just wraps the strategy
    ManualYieldStrategy public manualStrategy;

    struct ReportResult {
        uint256 balance;
        uint256 profit;
        uint256 loss;
    }

    function setUp() public override {
        super.setUp();

        asset = ERC20(tokenAddrs["USDC"]);

        manualStrategy = new ManualYieldStrategy(
            address(asset),
            "ManualYieldStrategy 20250224"
        );
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
        uint256 initialBalance = 0;
        reportAndAssert(ReportResult(0, 0, 0), "report wrong on init");

        // mint some deposits into strategy
        uint256 depositAmount = 1_000e18;
        mintAndDepositIntoStrategy(
            IStrategyInterface(address(manualStrategy)),
            user,
            depositAmount
        );

        reportAndAssert(
            ReportResult(depositAmount, 0, 0),
            "report wrong after deposit"
        );

        // ========================== borrow ==========================
        uint256 prevManagementBalance = asset.balanceOf(address(management));

        vm.prank(management);
        manualStrategy.borrow(depositAmount);

        assertEq(
            asset.balanceOf(management),
            prevManagementBalance + depositAmount,
            "manager should have borrowed depositAmount"
        );

        reportAndAssert(
            ReportResult(depositAmount, 0, 0),
            "report wrong after borrow"
        );

        // ========================== repay partial ==========================
        uint256 partialRepayAmount = 250e18;
        repay(partialRepayAmount);
        reportAndAssert(
            ReportResult(depositAmount, 0, 0),
            "report wrong after partial repayment"
        );

        // ========================== repay remainder ==========================
        uint256 remainderRepayAmount = depositAmount - partialRepayAmount;
        repay(remainderRepayAmount);
        reportAndAssert(
            ReportResult(depositAmount, 0, 0),
            "report wrong after remainder repayment"
        );

        // ========================== repay with yield ==========================
        uint256 yield = depositAmount / 100; // mimic 1% yield
        airdrop(asset, management, yield);
        repay(yield);
        reportAndAssert(
            ReportResult(depositAmount + yield, yield, 0),
            "report wrong after yield"
        );
    }


    function repay(uint256 amount) public {
        vm.startPrank(management);
        asset.approve(address(manualStrategy), amount);
        manualStrategy.repay(amount);
        vm.stopPrank();
    }

    function reportAndAssert(
        ReportResult memory expectedReportResult,
        string memory assertMsg
    ) public {

        vm.startPrank(address(keeper));
        (uint256 profit, uint256 loss) = tokenizedStrategy.report();
        vm.stopPrank();

        assertEq(
            profit,
            expectedReportResult.profit,
            string.concat(assertMsg, " - report profit")
        );
        assertEq(
            loss,
            expectedReportResult.loss,
            string.concat(assertMsg, " - report loss")
        );

        assertEq(
            expectedReportResult.balance,
            tokenizedStrategy.totalAssets(),
            string.concat(assertMsg, " - assets")
        );
    }
}
