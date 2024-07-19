// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract AuctionEngine {

    address public owner; // engine owner
    uint constant DURATION = 2 days; // 2 * 24h * 60min * 60sec
    uint constant FEE = 10; //10%


    struct Auction {
        address payable seller;
        uint startPrice;
        uint finalPrice;
        uint startAt;
        uint endAt;
        uint discountRate; // price reduction during time;
        
        string item; // auction item;
        bool ended;
    }
    
    Auction[] public auctions; // all our actions;
    
    constructor() {
        owner = msg.sender;
    }

    event AuctionCreated(uint index, string itemName, uint startingPrice, uint duration);
    event AuctionEnded(uint index, uint finalPrice, address winner);


    function createAuction(uint _startingPrice, uint _discountRate, string calldata _item, uint _duration) external {
        uint duration = _duration == 0 ? DURATION : _duration;

        require(_startingPrice >= _discountRate * duration, "Incorrect starting price");
        Auction memory newAuction = Auction({
            seller: payable(msg.sender),
            startPrice: _startingPrice,
            finalPrice: _startingPrice,
            startAt: block.timestamp,
            endAt: block.timestamp + duration,
            discountRate: _discountRate,
            item: _item,
            ended: false
        });

        auctions.push(newAuction);
        emit AuctionCreated(auctions.length - 1, _item, _startingPrice, duration);
    }

    function getPriceFor(uint index) public view returns(uint)  {
        Auction memory currentAuction = auctions[index];
        require(!currentAuction.ended, "Auction ended!");
        uint elapsed = block.timestamp - currentAuction.startAt;
        uint discount = currentAuction.discountRate * elapsed; // current value of discount

        return currentAuction.startPrice - discount;
    }


    function buy(uint index) external payable {
        Auction storage currentAuction = auctions[index];
        require(!currentAuction.ended, "Auction ended!");
        require(block.timestamp < currentAuction.endAt, "Auction ended!");
        uint currentPrice = getPriceFor(index);
        require(msg.value >= currentPrice, "Not enough funds");

        currentAuction.ended = true;
        currentAuction.finalPrice = currentPrice;

        // If we received more than final price we need to refund
        uint refund = msg.value - currentPrice;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        // Give a share to seller and platform fee
        currentAuction.seller.transfer(currentPrice - ((currentPrice * FEE) / 100));

        emit AuctionEnded(index, currentPrice, msg.sender);
    }
}
