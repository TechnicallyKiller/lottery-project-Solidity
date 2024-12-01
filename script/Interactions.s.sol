// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.10;
import {Script} from "forge-std/Script.sol";
import {HelperConfig,CodeConstants} from "./HelperConfig1.s.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

import {console} from "forge-std/console.sol";
import {VRFCoordinatorV2_5Mock} from "../lib/chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";


contract CreateSubscription is Script {
    function CreateSubscriptionUsingConfig() public returns (uint256 subid , address vrfCoordinator) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator1 = helperConfig.getConfig().vrfCoordinator;
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

contract FundSubscription is Script , CodeConstants {
    uint256 public constant FUND_AMOUNT = 3 ether;
    function run() public {
        fundSubscriptionusingConfig();

    }
    
    function fundSubscriptionusingConfig() public {
         HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator1 = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionID = helperConfig.getConfig().subscriptionId;
        address linkToken = helperConfig.getConfig().link;
        fundSubscription(vrfCoordinator1,subscriptionID,linkToken);




    }
    function fundSubscription(address vrfCooordinator, uint256 subId, address linktoken) public {

    //  VRFCoordinatorV2_5Mock(vrfCooordinator).fundSubscription(subId,FUND_AMOUNT);
        console.log("chain id :", block.chainid);
        if(block.chainid==LOCAL_CHAIN_ID){
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCooordinator).fundSubscription(subId,FUND_AMOUNT);
            vm.stopBroadcast();
        }
        else{
            vm.startBroadcast();
            LinkToken(linktoken).transferAndCall(vrfCooordinator,FUND_AMOUNT, abi.encode(subId));
            vm.stopBroadcast();
        }
    }
}


contract AddConsumer is Script {
       function run() external {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment("MyContract", block.chainid);
        addConsumerusingConfig(mostRecentDeployment);

    }

    function addConsumerusingConfig(address mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator1 = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionID = helperConfig.getConfig().subscriptionId;
        addConsumer(mostRecentlyDeployed,subscriptionID,vrfCoordinator1);
    }

    function addConsumer(address contractToAddConsumer , uint256 subId , address vrfCoord) public {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoord).addConsumer(subId,contractToAddConsumer);
        vm.stopBroadcast();

    }
}