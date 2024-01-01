// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script{

    function run() external returns (FundMe){
        //anything before startBroadcast --> not a real txn
        //we can create a mock contract to avoid hard coding any address here...
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        //anything after startBroadcast --> Real txn
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}