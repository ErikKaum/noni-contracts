//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract Noni is ERC721, ERC721URIStorage, ERC721Enumerable, Ownable {
    
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    
    string baseSVG = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: black; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='#F1F9F5' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
    
    struct Bid {
        uint256 bid;
        address bidder;
        bytes32 pubkey;
    }

    struct NoniInfo {
        string name;
        string imageURI;        
        uint elo;
        string contentID;
        bool forSale;
        mapping(uint256 => Bid[]) bid;
    }

    // Get info of specific Noni at index
    mapping(uint256 => NoniInfo) public noniInfos;

    event NewCID (address owner);
    event Minted (address owner, uint256 tokenId);

    constructor() ERC721("Noni", "NONI") {
    }

    //default contendID QmNQ1ABiGJ9fv9wzxf1k1eKbc8nvXBQw7VnQSNedeRwwfo
    function safeMint(string memory cid) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        string memory finalSvg = string(abi.encodePacked(baseSVG, tokenId.toString(), "</text></svg>"));

        // noniInfos[tokenId] = NoniInfo({
        //     name: string(abi.encodePacked("0xNoni", tokenId.toString())),
        //     imageURI: Base64.encode(abi.encodePacked(finalSvg)),
        //     elo: 400,
        //     contentID: cid,
        //     forSale: false
        //     });
        
        NoniInfo storage noni = noniInfos[tokenId];
        noni.name = string(abi.encodePacked("0xNoni", tokenId.toString())); 
        noni.imageURI = Base64.encode(abi.encodePacked(finalSvg));
        noni.elo = 400;
        noni.contentID = cid;
        noni.forSale = false;

        _safeMint(msg.sender, tokenId);

        emit Minted(msg.sender, tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        
        // NoniInfo memory info = noniInfos[tokenId];

        string memory name = noniInfos[tokenId].name;
        string memory imageURI = noniInfos[tokenId].imageURI;
        uint256 elo = noniInfos[tokenId].elo;
        string memory contentID = noniInfos[tokenId].contentID;

        bool forSale = noniInfos[tokenId].forSale;
        uint256 forSaleAsInt = boolToUInt256(forSale);

        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "', name,'",',
                '"imageURI": "data:image/svg+xml;base64,', imageURI,'",',
                '"elo": "', elo.toString() ,'",',
                '"contentID": "',contentID,'",',
                '"forSale": "',forSaleAsInt.toString(),'",',
                '"description": "Train your AI and battle against others!','",',
                '"attributes": [{ "trait_type": "elo", "value": ',elo.toString(),' } ]'
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );

    }

    function updateCID(uint256 tokenId, string memory newContentID) public {
        require(ownerOf(tokenId) == msg.sender);
        
        noniInfos[tokenId].contentID = newContentID;
        emit NewCID (msg.sender);

    }

    // Set the forSale property of a noni to either true or false
    function setSaleState(uint256 tokenId, bool state) public {
        require(ownerOf(tokenId) == msg.sender);

        noniInfos[tokenId].forSale = state;

        if (state == false) {
            delete noniInfos[tokenId].bid[tokenId];
        }
    }

    function updateElo(uint256 tokenId, uint256 newElo) public {
        require(ownerOf(tokenId) == msg.sender);
 
        noniInfos[tokenId].elo = newElo;
    }

    function placeBid(uint256 tokenId, uint256 amount, bytes32 pubKey) public {
        noniInfos[tokenId].bid[tokenId].push(Bid(amount, msg.sender, pubKey));     
    }

    function getBids(uint256 tokenId) public view returns(Bid[] memory) {
        return noniInfos[tokenId].bid[tokenId];
    }

    function transfer(address _from, address _to, uint256 tokenId, string memory newContentID) external {
        // Delete all bids so that they are not there for the next owner
        delete noniInfos[tokenId].bid[tokenId];
        noniInfos[tokenId].forSale = false;

        updateCID(tokenId, newContentID);
        safeTransferFrom(_from, _to, tokenId);
    }

    function getNumberOfNonis() public view returns(uint256) {
        return _tokenIdCounter.current(); 
    } 


    // Required by solidity to override
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function boolToUInt256(bool x) internal pure returns (uint256 r) {
        assembly { r := x }
    }



}
