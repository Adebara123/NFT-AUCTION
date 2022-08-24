// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract auction  is ERC721URIStorage{
    // a function where nft is minted to the winer can call that function 
    // a state variable where price can be changed as people keep auctioning
    // a function people can use to change the auction price, it cannot be changed to a lesser value 
    // a function people can use to sender their wins but can't send it unless they pay the price bided
    // a function where the ower can set an initial price of the auction
    // create a time to stop the aution 

    address owner;
    uint current_NFTprice;
    uint auction_time; 


   using Counters for Counters.Counter;

   mapping (address => uint) participantPrices;
   address[] participantAddress;

   event bidders(address bidder, uint amount);

    Counters.Counter private _myCounter;
    uint256 MAX_SUPPLY = 1;

    constructor(uint _auction_time) ERC721("Ayomide", "AYO") {
      owner  = msg.sender ;
      auction_time = _auction_time + block.timestamp;
    }

    modifier onlyOwner () {
        require(msg.sender == owner, "You can't call this function");
        _;
    }

    function safeMint(address to, string memory uri) private{
        uint256 tokenId = _myCounter.current();
        require(tokenId <= MAX_SUPPLY, "Sorry, all NFTs have been minted!");
        _myCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }
    

    function setInitialPrice(uint _NFTPrice) external onlyOwner {
        current_NFTprice = _NFTPrice;  
    }

    function auctionNFT (uint _auctionPrice) external {
        require(auction_time >block.timestamp, "Auction has ended");
        require (_auctionPrice > current_NFTprice, "Price too low, auction higher");
        current_NFTprice = _auctionPrice;
        participantPrices[msg.sender] = _auctionPrice;
        participantAddress.push(msg.sender);
        emit bidders(msg.sender, _auctionPrice);
    }

      function highestBidder (string memory uri) external payable{
        address winner = participantAddress[participantAddress.length - 1];
        require (msg.sender == winner, "You are not the higgest bidder");
        require (msg.value >= current_NFTprice, "You can't get it lower than you bidded");
        require(msg.sender != address(0), "Can't mint to this address");
        safeMint(msg.sender, uri);
    }

    function checkBid () public view returns(uint) {
       return  participantPrices[msg.sender];
    }

    function getAllBidders () public view returns(address[] memory addresses) {
        addresses = participantAddress;
    }

    function getFundsOut() external onlyOwner {
        require(msg.sender != address(0), "Can't withdraw to this address");
        payable(msg.sender).transfer(address(this).balance); 
    }

    receive () external payable {}

}