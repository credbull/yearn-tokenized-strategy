// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { TokenizedStaker } from "@periphery/Bases/Staker/TokenizedStaker.sol";
import { ITokenizedStaker } from "@periphery/Bases/Staker/ITokenizedStaker.sol";
import "../../../script/Deploy.s.sol";
import {Test} from "forge-std/Test.sol";

contract DeployTest is Test {

    function test__Deploy__Deploy() public {

        Deploy deploy = new Deploy();
        ITokenizedStaker staker = ITokenizedStaker(
            address(deploy.run())
        );

        assertNotEq(address(0), address(staker));
        assertNotEq(address(0), address(staker.asset()));
    }

}