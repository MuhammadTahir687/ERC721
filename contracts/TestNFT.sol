// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './ERC721Tradable.sol';


contract TestNFT is ERC721Tradable{

    constructor() ERC721Tradable("ARCADM", "ARC",0x465cD41394Eb35931f39fdd8507A230FF362f986,"https://gateway.pinata.cloud/ipfs/Qmcrnu7D3q14XDBjUNA3TsHFAxyiRGdz7fgLSkZWNXm7VG/") {}

}