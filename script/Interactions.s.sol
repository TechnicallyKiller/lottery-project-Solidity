// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.10;
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig1.s.sol";

contract CreateSubscription is Script {
    function CreateSubscriptionUsingConfig() public returns (uint256 subid , address vrfCoordinator) {
        HelperConfig helperconfig = new HelperConfig();
        address vrfCoordinator1 = helperconfig.getConfig().vrfCoordinator;
        (uint256 subId,)=createSubscription(vrfCoordinator1);
        return (subId,vrfCoordinator1);

    }
    function createSubscription(address vrfCoordinator ) public returns (uint256, address) {
        console.log("Creating subscription ON CHAIN LINK :",block.chainid);
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Your Subscription Id is :", subId);
        return (subId,vrfCoordinator);
    }
    function run() public {
        CreateSubscriptionUsingConfig();
    }
}