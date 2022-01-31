pragma solidity ^0.8.0;

import './ERC721Tradable.sol';


contract TestNFT is ERC721Tradable{

    constructor() ERC721Tradable("AR-CADUM", "ARC",0x84dDA0d57Bf4144f669542e0DD0F6B21389300Af,"https://gateway.pinata.cloud/ipfs/QmUePVdKQRcmT2ZHHELVqUrVupWUnLpSAedDAHif8PWnM6/") {}

}