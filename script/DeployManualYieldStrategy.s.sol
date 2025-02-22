//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { ManualYieldStrategy } from "../src/spikes/ManualYieldStrategy.sol";
import {DeployBase} from "./DeployBase.s.sol";

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";

contract DeployManualYieldStrategy is DeployBase {

    function run() public returns (ManualYieldStrategy strategy_) {
        return run(_yearnAuth);
    }

    function run(YearnAuth memory yearnAuth) public returns (ManualYieldStrategy strategy_) {
        ManualYieldStrategy strategy = _deploy();
        _init(strategy, yearnAuth);

        return strategy;
    }

    function _deploy() internal returns (ManualYieldStrategy strategy_) {
        vm.startBroadcast();

        // instantiate
        ManualYieldStrategy strategy = new ManualYieldStrategy(address(asset), "ManualYieldStrategy 20250222");

        // log
        console2.log(
            string.concat(
                "!!!!! Deploying ManualYieldStrategy [",
                vm.toString(address(strategy)),
                "] !!!!!"
            )
        );

        vm.stopBroadcast();

        return strategy;
    }
    
}
