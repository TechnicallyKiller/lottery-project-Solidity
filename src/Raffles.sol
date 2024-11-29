// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

import {VRFConsumerBaseV2Plus} from "chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {AutomationCompatibleInterface} from "chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";
import {VRFV2PlusClient} from "chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

// Layout of the contract file:
// version
// imports
// errors
// interfaces, libraries, contract

// Inside Contract:
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private


// view & pure functions
/**
 * @title A sample Raffle Contract by DivK
 * @author DivK
 * @notice This contract is for creating a raffle
 * @dev It implements Chainlink VRFv2.5 and Chainlink Automation
 */


contract Raffle is VRFConsumerBaseV2Plus, AutomationCompatibleInterface {
    error Raffle_NotEnoughEthSent();
    error Raffle_SendMoreToEnterRaffle();
    error Raffle_TransferFailed();
    error Raffle_RaffleNotOpen();
    error raffle_notUpdated(uint256 hehe , uint256 h2h, uint256 raFFLE);
    event PickedWinner(address player);
    event IndexedMembers(address indexed player);
    address payable[] private s_addresses;
    // Chainlink VRF related variables
    enum Raffle_State {
        OPEN,
        CALCULATING
    }

    
    Raffle_State private s_raffleState;
    uint16 private constant REQUEST_CONFIRMATIONS=3;
    uint32 private constant NUM_WORDS=1;
    uint32 private immutable i_callbackGasLimit;
    uint256 private immutable i_entrancefee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    address payable[] private s_players;
    uint256 private s_lasttimeStamp;
    address private s_recentWinner;




    constructor(uint256 entrancefee, uint256 timeinterval, address vrfCoordinator, bytes32 gasLane, uint256 subscriptionId, uint32 callbackGasLimit)VRFConsumerBaseV2Plus(vrfCoordinator){
        
        i_entrancefee=entrancefee;
        i_interval=timeinterval;
        s_lasttimeStamp=block.timestamp;
        i_keyHash= gasLane;
        i_callbackGasLimit= callbackGasLimit;
        s_raffleState=Raffle_State.OPEN;
        i_subscriptionId=subscriptionId;
        

        
    }


    function enterRaffle() external payable{
    if(msg.value < i_entrancefee) revert Raffle_NotEnoughEthSent();
    if(s_raffleState!=Raffle_State.OPEN) revert Raffle_RaffleNotOpen();
    s_players.push(payable(msg.sender));
    emit IndexedMembers(msg.sender);

    }
    /**
 * @dev This is the function that the Chainlink Keeper nodes call
 * they look for `upkeepNeeded` to return True.
 * the following should be true for this to return true:
 * 1. The time interval has passed between raffle runs.
 * 2. The lottery is open.
 * 3. The contract has ETH.
 * 4. There are players registered.
 * 5. Implicity, your subscription is funded with LINK.
 */
    function checkUpkeep(bytes memory /*data */) public view returns (bool upkeepNeeded , bytes memory /* performData */) {
        bool isOpen = Raffle_State.OPEN== s_raffleState;
        bool timepassed = (block.timestamp-s_lasttimeStamp)>=i_interval;
        bool hasPlayers = s_players.length>0;
        bool hasETH= address(this).balance>0;
        upkeepNeeded= (isOpen && timepassed && hasETH && hasPlayers);
        return(upkeepNeeded, "0x0");


    }
    function  performUpkeep(bytes calldata /* perform data */ ) external override {
        (bool upkeepNeeeded ,)= checkUpkeep("");
        if(!upkeepNeeeded){
            revert raffle_notUpdated(address(this).balance,
            s_players.length,
            uint256(s_raffleState));
        }
        
            s_raffleState=Raffle_State.CALCULATING;
            VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });
            uint256 requestId= s_vrfCoordinator.requestRandomWords(request);
    }
    function fulfillRandomWords(uint256 requestID, uint256[] calldata randomWords) internal override {
        uint256 indexOfWinner=randomWords[0]%s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner=winner;
        s_raffleState=Raffle_State.OPEN;
        s_players= new address payable[](0);
        s_lasttimeStamp=block.timestamp;



        (bool success,)=s_recentWinner.call{value:address(this).balance}("");
        if(!success){
            revert Raffle_TransferFailed();

        }
        
        emit PickedWinner(s_recentWinner);
        


    }
    
    /**GETTER FUNCTION
     */
    function getEntrancefee() external view returns(uint256){
        return i_entrancefee;
    }
    function getState() external view returns(Raffle_State){
        return s_raffleState;
    }
    function getPlayer(uint256 indexofPlayer) external view returns(address){
        return s_players[indexofPlayer];
    }
    

}