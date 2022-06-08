// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import './extensions/ERC721AQueryable.sol';
import "@openzeppelin/contracts/access/Ownable.sol";

contract MidnightApes is ERC721AQueryable,Ownable {
    bool public revealed = false;

    string baseURI;
    string hiddenURI;

    address private  _owner;
    bool public freeMint = true;

    uint256 public mintPrice = 0.05 ether;
    uint256 startTime;
    bool public started = false;

    uint128 public constant MAX_TOKENS = 10000;
    uint128 public constant ADMIN_AMOUNT = 500;
    uint128 public constant FREE_AMOUNT = 2500;
    uint256 public adminCount = 0;


    constructor(string memory _hiddenURI) ERC721A("Midnight Bird Ape Yacht Club", "MidnightApes") {
        hiddenURI = _hiddenURI;
        _owner = payable(msg.sender);
    }

    function mint(uint256 quantity) external  payable  {

        require(started,"not started to sell");

        require(totalMinted() + quantity<= MAX_TOKENS,"Over Total NFTs");

        if(freeMint){
            if(totalMinted() >= FREE_AMOUNT){
                freeMint = false;
            }
            if(startTime + 5 hours <= block.timestamp){
                freeMint = false;
            }
        }

        if(freeMint){
            require(quantity <=  5,"Over mint limit for one transaction in free sale");
            require(numberMinted(msg.sender) + quantity <= 10,"Over free mint amount");
        }else{
            require(quantity <=  20,"Over mint limit for one transaction in public sale");

            uint256 price = mintPrice * quantity; 

            require(msg.value >= price, "not enough funds");

            uint256 adminRemained =  ADMIN_AMOUNT - adminCount;

            require(totalMinted() + quantity  + adminRemained <= MAX_TOKENS,"Over mint amount than possible to mint");
        }

        _safeMint(msg.sender, quantity);
    }

    function setMintPrice(uint256 _price) external onlyOwner {
        mintPrice = _price;
    }

    function startMint() external onlyOwner {
        startTime = block.timestamp;
        started =  true;
    }

    function adminMint(uint256 quantity) external onlyOwner  {
        require(quantity <= 100,"Over nft amount in one claim");
        require(adminCount + quantity <= ADMIN_AMOUNT,"Over admin nft claim");
        adminCount += quantity;
        _safeMint(msg.sender, quantity);
    }

    function getOwnershipAt(uint256 index) public view returns (TokenOwnership memory) {
        return _ownershipAt(index);
    }


    function numberBurned(address owner) public view returns (uint256) {
        return _numberBurned(owner);
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    function totalMinted() public view returns (uint256) {
        return _totalMinted();
    }

    function totalBurned() public view returns (uint256) {
        return _totalBurned();
    }

    function nextTokenId() public view returns (uint256) {
        return _nextTokenId();
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        require(!revealed,"Not possible to change the baseURI after revealed");
        baseURI = _baseURI;
    }

    function sethiddenMetadataURI(string memory _hiddenURI) external  onlyOwner {
       hiddenURI = _hiddenURI;
    }


    function revealNFT() external onlyOwner  {
        revealed = true;
    }


    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721A,IERC721A)
        returns (string memory)
    {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        if(revealed == false){
            return hiddenURI;
        }

        string memory _tokenURI =  bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI,"/", _toString(tokenId), ".json")) : '';
        return _tokenURI;
    }

    function getOwnershipOf(uint256 index) public view returns (TokenOwnership memory) {
        return _ownershipOf(index);
    }

    function withdrawETH(address recipient, uint256 amount) external  onlyOwner {
        require(address(this).balance > 0, "Insufficient balance");
        (bool res,) = recipient.call{value : amount}("");
        require(res, "ETH TRANSFER FAILED");
    }
}
