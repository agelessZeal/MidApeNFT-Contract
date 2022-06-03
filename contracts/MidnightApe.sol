// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import './extensions/ERC721AQueryable.sol';
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MidnightApes is ERC721AQueryable,ReentrancyGuard {
    bool public revealed = false;

    string baseURI;
    string initialMetaData;

    address public  _owner;
    bool public freeMint = true;

    uint256 public mintPrice = 0.05 ether;
    uint256 startTime;
    bool started = false;


    constructor(string memory initData_) ERC721A("Midnight Bird Ape Yacht Club", "MidnightApes") {
        initialMetaData = initData_;
        _owner = payable(msg.sender);
    }

    function safeMint(uint256 quantity) external  payable nonReentrant  {

        require(started,"not started to sell");

        if(freeMint){
            if(totalMinted() >= 2500){
                freeMint = false;
            }
            if(startTime + 5 hours <= block.timestamp){
                freeMint = false;
            }
        }

        if(freeMint){
            require(quantity <=  2,"Over limit to mint at once");
            require(numberMinted(msg.sender) + quantity <= 2,"Over free mint amount");
        }else{
            require(quantity <=  10,"Over limit to mint at once");

            uint256 price = mintPrice * quantity; 

            require(msg.value >= price, "not enough funds");
        }

        _safeMint(msg.sender, quantity);
    }

    function setMintPrice(uint256 _price) external {
        require(msg.sender == _owner, "Error, you are not the owner");
        mintPrice = _price;
    }

    function startMint() external {
        require(msg.sender == _owner, "Error, you are not the owner");
        startTime = block.timestamp;
        started =  true;
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

    function getAux(address owner) public view returns (uint64) {
        return _getAux(owner);
    }

    function setAux(address owner, uint64 aux) external {
        _setAux(owner, aux);
    }


    function setBaseURI(string memory _baseURI) external {
        require(msg.sender == _owner, "Error, you are not the owner");
        require(!revealed,"Not possible to change the baseURI after revealed");
        baseURI = _baseURI;
    }

    function revealNFT() external {
        require(msg.sender == _owner, "Error, you are not the owner");
        revealed = true;
    }


    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721A)
        returns (string memory)
    {

        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        if(!revealed){
            return initialMetaData;
        }

        string memory _tokenURI =  bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI,"/", _toString(tokenId), ".json")) : '';
        return _tokenURI;
    }

    function toString(uint256 x) public pure returns (string memory) {
        return _toString(x);
    }

    function getOwnershipOf(uint256 index) public view returns (TokenOwnership memory) {
        return _ownershipOf(index);
    }

    function initializeOwnershipAt(uint256 index) external {
        _initializeOwnershipAt(index);
    }

    function withdrawETH(address recipient, uint256 amount) external  {
        require(msg.sender == _owner, "Error, you are not the owner");
        require(address(this).balance > 0, "Insufficient balance");
        (bool res,) = recipient.call{value : amount}("");
        require(res, "ETH TRANSFER FAILED");
    }
}
