//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {SimpleTokenizedStaker} from "../src/spikes/SimpleTokenizedStaker.sol";
import {ERC20} from "@tokenized-strategy/BaseStrategy.sol";

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";

contract Deploy is Script {

    ERC20 private asset;

    error UnknownChain(uint256 chainId);

    // Mainnets:
    // Testnets: arbSepolia=421614
    constructor() {
        if (block.chainid == getChain("anvil").chainId) {
            asset = ERC20(makeAddr("testToken"));
        }
        else if (block.chainid == 421614) { // arbSepolia=421614
            asset = ERC20(0x7F0d265E757A402eafFC3Cb80b0FFB6c32F1E3eF); // Arb Sepolia TestToken
        } else if (block.chainid == 42161) { // arbitrumOne=42161
            asset = ERC20(0x788Fe989Fadcfefb68861303f763dD1b0A9e1264); // Arb TestToken
        } else {
            revert UnknownChain(block.chainid);
        }
    }

    function run() public returns (SimpleTokenizedStaker tokenizedStaker_) {
        vm.startBroadcast();

        // instantiate
        SimpleTokenizedStaker tokenizedStaker = new SimpleTokenizedStaker(address(asset), "TestTokenStaker 20250221");

        // log
        console2.log(
            string.concat(
                "!!!!! Deploying SimpleTokenizedStaker [",
                vm.toString(address(tokenizedStaker)),
                "] !!!!!"
            )
        );

        // TODO - set these as well...

//        staker.setKeeper(keeper);
//        staker.setPerformanceFeeRecipient(performanceFeeRecipient);
//        staker.setPendingManagement(management);
//        // Accept management.
//        vm.prank(management);
//        staker.acceptManagement();
//
//        // Add initial reward token
//        vm.prank(management);
//        staker.addReward(address(rewardToken), management, duration);
//
//        // TODO - separate protocolFeeRecipient out from governance.  in yearn-tok-strat-periph it is address(56)
//        protocolFeeRecipient = IFactory(factory).governance();
        vm.stopBroadcast();

        return tokenizedStaker;
    }
}
