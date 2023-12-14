// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Before starBroadcast -> Not a "real" tx
        HelperConfig helperConfig = new HelperConfig();
        address ehtUsdPriceFeed = helperConfig.activeNetworkConfig();

        // After startBroadcast -> Real tx
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ehtUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
