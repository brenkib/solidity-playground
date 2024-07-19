// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {BRC721Token} from "./BRC721Token.sol";

// Market place for our token and price increase with each sold item
contract NFTMarketplace is BRC721Token {

    uint256 private _nextTokenId;
    uint8 constant LIST_PRICE = 0;
    uint256 private _currentPrice; // = 30; or in constructor when deployed
    //The structure to store info about my listed token
    struct ListedToken {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool currentlyListed;
    }

    uint256[] private _listedTokenIds;
    mapping(uint256 => ListedToken) public ListedNFTs;
    constructor(uint256 initPrice) BRC721Token(msg.sender){
        _currentPrice = initPrice;
        // Owner gets initial nft if needed
        safeMint(owner());
    }

    // Because our price should be increased for every sold NFT we need to restrict minting to only on-buy function
    function safeMint(address to) private override onlyOwner returns(uint256){
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        ListedNFTs[_nextTokenId] = ListedToken(_nextTokenId, to, owner(), _currentPrice, true);
        _listedTokenIds.push(tokenId);
        return tokenId;
    }

    function  viewAllListedNFTs() public view returns (uint256[] memory) {
        return _listedTokenIds;
    }

    function buyNFT() external payable {
        require(msg.value >= _currentPrice, "Not enough Ether to buy NFT");
        // Owner gets to mint new NFT
        uint tokenID = safeMint(owner());

        // transfer ownership
        address seller = ListedNFTs[tokenID].owner;
        ListedNFTs[tokenID].currentlyListed = false;
        safeTransferFrom(seller, msg.sender, tokenID, "");
        // For more complex versions where
        //payable(idToListing[listingId].seller).transfer((idToListing[listingId].price * amount/50)*49); //Transfering 98% to seller, fee 2%  ((msg.value/50)*49)

        // updating the price for the next buyer -> 5% increase
        _currentPrice = _currentPrice * 105 / 100;
    }
}
