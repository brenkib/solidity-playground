// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC721, ERC721Base} from "./ERC721.sol";

contract ERC721URIStorage is ERC721Base {
    mapping(uint => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view virtual override _requireMinted(tokenId) returns (string memory) {
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory _baseURI = _baseURI();

        if(bytes (_baseURI).length == 0) {
            return _tokenURI;
        }
        if(bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual _requireMinted(tokenId) {
        _tokenURIs[tokenId] = _tokenURI;
    }

    function burn(uint tokenId) public override  {
        super.burn(tokenId);
        if(bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
