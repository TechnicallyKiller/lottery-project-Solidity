// SPDX-License-Identifier: MIT
pragma solidity 0.8.10^;
import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "lottery-project-Solidity/lib/chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";




error HelperConfig_InvalidChainId();

abstract contract CodeConstants {
    uint256 public constant ETH_SEPOLIA_CHAIN_ID=11155111;
    uint256 public constant LOCAL_CHAIN_ID;

}

contract HelperConfig is CodeConstants,Script {
    struct NetworkConfig{
        uint256 interval;
        uint256 entranceFee;
        bytes32 gaslane;
        uint256 subscriptionId;
        address vrfCoordinator;
        uint32 callbackGasLimit;
    }
    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID]=getSepoliaConfig();
    }
    function getConfigByChainID(uint256 chainId) public returns(NetworkConfig memory){
        if(networkConfigs[chainId].vrfCoordinator!=address(0)){
            return networkConfigs[chainId];
        }
        else if(chainId==LOCAL_CHAIN_ID){
            //getorCreateAnvil
            return getOrCreateAnvilEthConfig();

        }
        else { 
            revert HelperConfig_InvalidChainId();

        }
    }
    function getConfig() public returns (NetworkConfig memoryu){
        return getConfigByChainID(block.chainid);
    }
    function getSepoliaConfig() public returns (NetworkConfig memory) {
        NetworkConfig memory SepoliaConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 2500000;
            subscriptionId: 0


        }
        );
        return SepoliaConfig;
    }
    function getOrCreateAnvilEthConfig() public view returns (NetworkConfig memory ){
        if(NetworkConfig.vrfCoordinator != address(0)){
            return localNetworkConfig;
        }
        /* VRF Mock Values */
        uint96 public constant MOCK_BASE_FEE = 0.25 ether;
        uint96 public constant MOCK_GAS_PRICE_LINK = 1e9;
        int256 public constant MOCK_WEI_PER_UNIT_LINK = 4e15;

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(
            MOCK_BASE_FEE,
            MOCK_GAS_PRICE_LINK,
            MOCK_WEI_PER_UNIT_LINK,
        );

        vm.stopBroadcast();
        localNetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorMock),
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 2500000;
            subscriptionId: 0


            });
            return localNetworkConfig;
    }

        }
