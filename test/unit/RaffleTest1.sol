// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "forge-std/console.sol";

import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffles.s.sol";
import {Raffle} from "../../src/Raffles.sol";
import {HelperConfig} from "../../script/HelperConfig1.s.sol";

contract RafflesTest is Test {
    Raffle public raffle;
    HelperConfig public helperConfig1;
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    uint256 subscriptionId;

    event IndexedMembers(address indexed player);

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE= 10 ether;



    function setUp() external {
        
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig1)= deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig1.getConfig();
        entranceFee=config.entranceFee;
        interval=config.interval;
        vrfCoordinator=config.vrfCoordinator;
        gasLane=config.gasLane;
        callbackGasLimit=config.callbackGasLimit;
        subscriptionId=config.subscriptionId;
        vm.deal(PLAYER,STARTING_PLAYER_BALANCE);

    }
    function testRaffleIntializesInOpenState() public view {
        Raffle.Raffle_State expectedState = Raffle.Raffle_State.OPEN;
        assert(raffle.getState() == expectedState);
    }
    function testRaffleRevertWhenYouDontPay() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle_NotEnoughEthSent.selector);
        raffle.enterRaffle();


    }

    function testraffflerecordsPlayers() public {
        vm.prank(PLAYER);

        raffle.enterRaffle{value: entranceFee}();
        address playerRecorded  = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }
    function testEmitsEventOnEntrance() public {
    // Arrange
    vm.prank(PLAYER); // Set PLAYER as the sender of the transaction

    vm.recordLogs();
     console.log("PLAYER Address: ", PLAYER);
    console.log("Entrance Fee: ", entranceFee);

    // Act / Assert
    // Expect the 'EnteredRaffle' event to be emitted with the PLAYER address as the indexed parameter
    vm.expectEmit(true, false, false, false, address(raffle)); // Expect the event from the raffle contract
    emit IndexedMembers(PLAYER); // Emitting the event manually for comparison
    raffle.enterRaffle{value: entranceFee}(); // Call the function to enter the raffle
}

function testDontAllowPlayersToEnterWhileRaffleIsCalculating() public {
    // Arrange
    vm.prank(PLAYER);
    raffle.enterRaffle{value: entranceFee}();
    vm.warp(block.timestamp + interval + 1);
    vm.roll(block.number + 1);
    raffle.performUpkeep("");

    // Act / Assert
    vm.expectRevert(Raffle.Raffle_RaffleNotOpen.selector);
    vm.prank(PLAYER);
    raffle.enterRaffle{value: entranceFee}();

}

    }