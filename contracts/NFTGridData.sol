// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./interfaces/ISpotGrid.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//v0.02 lastDeploy:0xb9Cc0EEf94A3f76e7c03633379B0923b360F6DC9
contract NFTGridData is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    mapping(uint=>address) public botAddress;
    
    constructor() ERC721("NFTGridData", "NGD") {}

    function safeMint(address to, string memory uri, address gridAddress) public {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        botAddress[tokenId]=gridAddress;    
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function getCurrentId() public view returns(uint) {
        return _tokenIdCounter.current();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        ISpotGrid grid = ISpotGrid(botAddress[tokenId]);
        grid.changeOwnerBot(to);
        super._beforeTokenTransfer(from,to,tokenId);
    }


    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}