// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffles.sol";
import {Raffle} from "../../src/Raffles.sol";

contracts RafflesTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig;
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    uint256 subscriptionId;



    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE= 10 ether;



    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig)= deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee=config.entranceFee;
        interval=config.interval;
        vrfCoordinator=config.vrfCoordinator;
        gasLane=config.gasLane;
        callbackGasLimit=config.callbackGasLimit;
        subscriptionId=config.subscriptionId;

    }
}