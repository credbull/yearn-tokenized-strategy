// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { ITokenizedStaker } from "@periphery/Bases/Staker/ITokenizedStaker.sol";

import { DeploySimpleTokenizedStaker } from "../../../script/DeploySimpleTokenizedStaker.s.sol";
import { DeployBase } from "../../../script/DeployBase.s.sol";

import {Test} from "forge-std/Test.sol";

contract DeploySimpleTokenizedStakerTest is Test {

    function test__DeploySimpleTokenizedStaker__Deploy() public {

        DeployBase.YearnAuth memory yearnAuth = DeployBase.YearnAuth({
            governance: makeAddr("governance"), // not used in Strategy
            emergencyAdmin: makeAddr("emergencyAdmin"),
            management: makeAddr("management"),
            keeper: makeAddr("keeper"),
            perfFeeRecipient: makeAddr("perfFeeRecipient")
        });

        DeploySimpleTokenizedStaker deploy = new DeploySimpleTokenizedStaker();
        ITokenizedStaker staker = ITokenizedStaker(
            address(deploy.run(yearnAuth))
        );

        assertNotEq(address(0), address(staker));
        assertNotEq(address(0), address(staker.asset()));

        // check roles setup
        // assertEq(staker.governance(), yearnAuth.governance, "governance not set"); // not on strategy
        assertEq(staker.emergencyAdmin(), yearnAuth.emergencyAdmin, "emergencyAdmin not set");
        assertEq(staker.pendingManagement(), yearnAuth.management, "pending management not set");
        assertEq(staker.keeper(), yearnAuth.keeper, "keeper not set");
        assertEq(staker.performanceFeeRecipient(), yearnAuth.perfFeeRecipient, "perfFeeRecipient not set");

        // 2-step process for management
        vm.prank(yearnAuth.management);
        staker.acceptManagement();

        assertEq(staker.management(), yearnAuth.management, "management not set");

    }

}