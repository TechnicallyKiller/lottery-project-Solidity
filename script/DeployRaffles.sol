// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffles.sol";
import {HelperConfig} from "./HelperConfig1.s.sol";


contract DeployRaffle is Script{
    function run() external returns (Raffle) {
    }
    function deployContract() public returns (Raffle , HelperConfig){
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
         vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.entranceFee;
            config.interval,
            config.vrfCoordinator,
            config.gaslane,
            config.subscriptionId,
            config.callbackGasLimit
        );
        vm.stopBroadcast();
        return (raffle,helperConfig);

        
    }
}