// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/AuctionHouse.sol";

contract DeployAuctionHouse is Script {
    function run() external {
        vm.startBroadcast(); // Start sending transactions

        // Deploy the contract
        AuctionHouse auctionHouse = new AuctionHouse();
        console.log("AuctionHouse deployed at:", address(auctionHouse));

        vm.stopBroadcast(); // Stop broadcasting transactions
    }
}


// 0x5b73C5498c1E3b4dbA84de0F1833c4a029d90519