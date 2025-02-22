//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { SimpleTokenizedStaker } from "../src/spikes/SimpleTokenizedStaker.sol";
import { ITokenizedStaker } from "@periphery/Bases/Staker/ITokenizedStaker.sol";
import { TokenizedStaker } from "@periphery/Bases/Staker/TokenizedStaker.sol";

import {DeployBase} from "./DeployBase.s.sol";
import { console2 } from "forge-std/console2.sol";

contract DeploySimpleTokenizedStaker is DeployBase {
    function run() public returns (TokenizedStaker staker_) {
        return run(_yearnAuth);
    }

    function run(YearnAuth memory yearnAuth) public returns (TokenizedStaker staker_) {
        TokenizedStaker staker = _deploy();
        _init(staker, yearnAuth);

        return staker;
    }

    function _deploy() internal returns (TokenizedStaker staker_) {
        vm.startBroadcast();

        // instantiate
        TokenizedStaker staker = new SimpleTokenizedStaker(address(asset), "TestTokenStaker 20250221");

        // log
        console2.log(
            string.concat(
                "!!!!! Deploying SimpleTokenizedStaker [",
                vm.toString(address(staker)),
                "] !!!!!"
            )
        );

        vm.stopBroadcast();

        return staker;
    }

}
