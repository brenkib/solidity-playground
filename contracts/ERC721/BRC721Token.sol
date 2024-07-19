// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721URIStorage} from "./ERC721URIStorage.sol";
import {Ownable} from "../utils/Ownable.sol";

contract BRC721Token is ERC721URIStorage, ERC721, Ownable {
    constructor(address initialOwner) ERC721URIStorage("BRC721Token", "BRT") Ownable(initialOwner) {}
}