// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AuctionHouse {
    struct Auction {
        address payable seller;
        uint256 startingPrice;
        uint256 highestBid;
        address highestBidder;
        uint256 endTime;
        bool finalized;
    }

    mapping(uint256 => Auction) public auctions;
    uint256 public auctionCount;

    event AuctionCreated(uint256 auctionId, address seller, uint256 startingPrice, uint256 endTime);
    event BidPlaced(uint256 auctionId, address bidder, uint256 amount);
    event AuctionFinalized(uint256 auctionId, address winner, uint256 winningBid);

    modifier onlyBeforeEnd(uint256 _auctionId) {
        require(block.timestamp < auctions[_auctionId].endTime, "Auction ended");
        _;
    }

    modifier onlyAfterEnd(uint256 _auctionId) {
        require(block.timestamp >= auctions[_auctionId].endTime, "Auction not ended yet");
        _;
    }

    modifier onlySeller(uint256 _auctionId) {
        require(msg.sender == auctions[_auctionId].seller, "Only seller can finalize");
        _;
    }

    function createAuction(uint256 _startingPrice, uint256 _duration) external {
        require(_duration > 0, "Duration must be greater than 0");

        uint256 auctionId = auctionCount++;
        auctions[auctionId] = Auction({
            seller: payable(msg.sender),
            startingPrice: _startingPrice,
            highestBid: _startingPrice,
            highestBidder: address(0),
            endTime: block.timestamp + _duration,
            finalized: false
        });

        
        

        
    }

    function placeBid(uint256 _auctionId) external payable onlyBeforeEnd(_auctionId) {
        Auction storage auction = auctions[_auctionId];
        require(msg.value > auction.highestBid, "Bid must be higher than current highest bid");

        // Refund the previous highest bidder
        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;

        emit BidPlaced(_auctionId, msg.sender, msg.value);
    }

    function finalizeAuction(uint256 _auctionId) external onlyAfterEnd(_auctionId) onlySeller(_auctionId) {
        Auction storage auction = auctions[_auctionId];
        require(!auction.finalized, "Auction already finalized");

        auction.finalized = true;
        if (auction.highestBidder != address(0)) {
            auction.seller.transfer(auction.highestBid);
        }

        emit AuctionFinalized(_auctionId, auction.highestBidder, auction.highestBid);
    }

    function getAuction(uint256 _auctionId) external view returns (Auction memory) {
        return auctions[_auctionId];
    }
}
