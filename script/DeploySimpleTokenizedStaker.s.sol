//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { SimpleTokenizedStaker } from "../src/spikes/SimpleTokenizedStaker.sol";
import { ITokenizedStaker } from "@periphery/Bases/Staker/ITokenizedStaker.sol";
import { TokenizedStaker } from "@periphery/Bases/Staker/TokenizedStaker.sol";

import {ERC20} from "@tokenized-strategy/BaseStrategy.sol";
import {TomlConfig} from "@credbull-script/TomlConfig.s.sol";
import {DeployBase} from "./DeployBase.s.sol";

import { stdToml } from "forge-std/StdToml.sol";
import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";

contract DeploySimpleTokenizedStaker is DeployBase {
    using stdToml for string;

    function run() public returns (TokenizedStaker staker_) {
        return run(_yearnAuth);
    }

    function run(YearnAuth memory yearnAuth) public returns (TokenizedStaker staker_) {
        TokenizedStaker staker = _deployStaker();
        _initStaker(staker, yearnAuth);

        return staker;
    }

    function _deployStaker() internal returns (TokenizedStaker staker_) {
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

    function _initStaker(TokenizedStaker stakerImpl, YearnAuth memory yearnAuth) public {

        ITokenizedStaker staker = ITokenizedStaker(address(stakerImpl));

        vm.startBroadcast();

        staker.setKeeper(yearnAuth.keeper);
        staker.setPerformanceFeeRecipient(yearnAuth.perfFeeRecipient);
        staker.setPendingManagement(yearnAuth.management);
        staker.setEmergencyAdmin(yearnAuth.emergencyAdmin);

        vm.stopBroadcast();
    }

}
