//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {SimpleTokenizedStaker} from "../src/spikes/SimpleTokenizedStaker.sol";
import {ITokenizedStaker} from "@periphery/Bases/Staker/ITokenizedStaker.sol";

import {ERC20} from "@tokenized-strategy/BaseStrategy.sol";
import {TomlConfig} from "@credbull-script/TomlConfig.s.sol";

import { stdToml } from "forge-std/StdToml.sol";
import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import {TokenizedStaker} from "../lib/tokenized-strategy-periphery/src/Bases/Staker/TokenizedStaker.sol";

contract Deploy is TomlConfig {
    using stdToml for string;

    string private _tomlConfig;

    ERC20 private asset;
    YearnAuth private _yearnAuth;

    error UnknownChain(uint256 chainId);

    struct YearnAuth {
        address governance; // address that owns the contract (owner)
        address emergencyAdmin; // can halt operators (owner)
        address management; // can set fees, profit unlocking time etc (operator)
        address keeper; // can report() to accrue p&l, charge fees, and lock profit to distribute (asset manager)

        // strategy specific ?
        address perfFeeRecipient; // perf fees are optional. (custodian)
        // address protocolFeeRecipient; // fee on the perf fees, sent to yearn treasury
    }

    // Mainnets:
    // Testnets: arbSepolia=421614
    constructor() {
        _tomlConfig = loadTomlConfigFromLib();

        _yearnAuth = YearnAuth({
            governance: _tomlConfig.readAddress(".evm.address.owner"),
            emergencyAdmin: _tomlConfig.readAddress(".evm.address.owner"),
            management: _tomlConfig.readAddress(".evm.address.operator"),
            keeper: _tomlConfig.readAddress(".evm.address.asset_manager"),
            perfFeeRecipient: _tomlConfig.readAddress(".evm.address.custodian")
        });

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

        // TODO - set these as well...
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


    function loadTomlConfigFromLib() internal view returns (string memory) {
        string memory environment = vm.envString("ENVIRONMENT");

        string memory path = string.concat(vm.projectRoot(), "/lib/credbull-defi/packages/contracts/resource/", environment, ".toml");
        console2.log(string.concat("Loading toml configuration from: ", path));
        return vm.readFile(path);
    }
}
