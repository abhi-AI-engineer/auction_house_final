// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/AuctionHouse.sol";
import "forge-std/console2.sol";

contract AuctionHouseTest is Test {
    AuctionHouse auctionHouse;
    address seller = address(1);
    address bidder1 = address(2);
    address bidder2 = address(3);

    function setUp() public {
        auctionHouse = new AuctionHouse();
        vm.deal(seller, 10 ether);
        vm.deal(bidder1, 10 ether);
        vm.deal(bidder2, 10 ether);
    }

    function testCreateAuction() public {
        vm.prank(seller);
        auctionHouse.createAuction(1 ether, 1 days);

        (address auctionSeller,, uint256 highestBid, , , ) = auctionHouse.auctions(0);
        assertEq(auctionSeller, seller);
        assertEq(highestBid, 1 ether);
    }

    function testPlaceBid() public {
        vm.prank(seller);
        auctionHouse.createAuction(1 ether, 1 days);

        vm.prank(bidder1);
        auctionHouse.placeBid{value: 2 ether}(0);

        (, , uint256 highestBid, address highestBidder, , ) = auctionHouse.auctions(0);
        assertEq(highestBid, 2 ether);
        assertEq(highestBidder, bidder1);
    }

    function testFinalizeAuction() public {
        vm.prank(seller);
        auctionHouse.createAuction(1 ether, 1 days);

        vm.prank(bidder1);
        auctionHouse.placeBid{value: 2 ether}(0);

        vm.warp(block.timestamp + 1 days);  // Move time forward

        vm.prank(seller);
        auctionHouse.finalizeAuction(0);

        (, , , , , bool finalized) = auctionHouse.auctions(0);
        assertTrue(finalized);
    }
}


