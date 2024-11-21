// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

import {VRFConsumerBaseV2Plus} from "chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
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
error Raffle_NotEnoughEthSent();
error Raffle_SendMoreToEnterRaffle();
error Raffle_TransferFailed();
error Raffle_RaffleNotOpen();

// view & pure functions
/**
 * @title A sample Raffle Contract by DivK
 * @author DivK
 * @notice This contract is for creating a raffle
 * @dev It implements Chainlink VRFv2.5 and Chainlink Automation
 */


contract Raffles is VRFConsumerBaseV2Plus{
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
        

        
    }


    function enterRaffle() external payable{
    if(msg.value < i_entrancefee) revert Raffle_NotEnoughEthSent();
    if(s_raffleState!=Raffle_State.OPEN) revert Raffle_RaffleNotOpen();
    s_players.push(payable(msg.sender));
    emit IndexedMembers(msg.sender);

    }
    function pickWinner() external {
        if(block.timestamp-s_lasttimeStamp<i_interval) revert();
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
            s_raffleState=Raffle_State.CALCULATING;
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
    

}