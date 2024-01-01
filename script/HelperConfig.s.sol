// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address across different chains
// sepolia ETH/USD and Mainnet ETH/USD  will have different addresses.
// So if we establich the HelperConfig.s.sol file correctly then we can work with the local chain and work with any chain no problem.abi

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    //If we are on a local anvil, we deploy mock contract on the local anvil
    // Otherwise, grab the existing  address from the live network

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if(block.chainid == 5){
            activeNetworkConfig = getSapoliaETHConfig();
        }
        else if(block.chainid == 1){
            activeNetworkConfig = getMainnetETHConfig();
        }
        else {
            activeNetworkConfig = getOrCreateAnvilETHConfig();
        }
    }

    function getSapoliaETHConfig() public pure returns (NetworkConfig memory){
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetETHConfig() public pure returns (NetworkConfig memory){
        //price feed address
        NetworkConfig memory EthConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return EthConfig;
    }

    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory){
        
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        
        //deploy the mocks
        //return the mock addresses

        vm.startBroadcast(); 
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}