// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "./ContentMixin.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @title ERC721Tradable
 * ERC721Tradable - ERC721 contract that whitelists a trading address, and has minting functionality.
 */
contract ERC721Tradable is ContextMixin, ERC721PresetMinterPauserAutoId, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

     Counters.Counter private _tokenIdTracker;
     uint256 private _price=100000000000000000;
     uint256 private _presalePrice=10000000000000000;
     uint256 private _maxSupply=2012;
     uint256 private _maxPresaleSupply=25;
     address private _owner=0x29892C3e8282fD8809A2a08c892c55e00Be50937;
     address public proxyRegistryAddress;
     struct my_struct {uint256 a;}
     mapping (address=>my_struct) tokenlimit;

    constructor(
        string memory _name,
        string memory _symbol,
        address _proxyRegistryAddress,
        string memory _baseURI
    ) ERC721PresetMinterPauserAutoId(_name, _symbol,_baseURI) {
        proxyRegistryAddress = _proxyRegistryAddress;

    }

    // /**
    //  * @dev Mints a token to an address with a tokenURI.
    //  * @param _to address of the future owner of the token
    //  * @param _tokenId address of the future owner of the token
    //  */

    function PresalePrice(uint256  Presale_Price ) public   {
        require(msg.sender==_owner,"You are not a owner");
         _presalePrice = Presale_Price; 
    }

     function PresaleSupply(uint256  Presale_Supply ) public   {
         require(msg.sender==_owner,"You are not a owner");
         _presalePrice = Presale_Supply; 
    }

    function mintTo(address _to ) payable public virtual {
           tokenlimit[msg.sender].a += 1;
         require( tokenlimit[msg.sender].a < 10,"Only Two NFT Mint Per Address");
          require(totalSupply() <= _maxSupply,"All Tokens Mint");
          require(msg.value >= _price,"Not Enough Ether");
          payable(0x465cD41394Eb35931f39fdd8507A230FF362f986).transfer(msg.value);
         _tokenIdTracker.increment();
           _mint(_to, _tokenIdTracker.current());
    }
    
    function Presale(address _to) payable public virtual{
         tokenlimit[msg.sender].a += 1;
         require( tokenlimit[msg.sender].a < 2,"Only Two NFT Mint Per Address");
         require(totalSupply() <= _maxPresaleSupply);
         require(msg.value >= _presalePrice,"Not Enough Price to mint");
         payable(0x465cD41394Eb35931f39fdd8507A230FF362f986).transfer(msg.value);
        _tokenIdTracker.increment();
        _mint(_to, _tokenIdTracker.current());
    }

    function OwnerPresale(address _to,uint256 tokens) public {
        require(msg.sender==_owner,"You are not a owner");
         require(totalSupply() <= _maxPresaleSupply);
        for(uint256 i=1; i<=tokens; i++)
        {
            _tokenIdTracker.increment();
         _mint(_to, _tokenIdTracker.current());
         
         }
    }

    function baseTokenURI() virtual public view returns (string memory){
        return _baseURI();
    }

     function presaleMaxSupply()  public view returns(uint256) {
        return _maxPresaleSupply;
    }

    function presalePrice()  public view returns(uint256) {
        return _presalePrice;
    }


    function tokenURI(uint256 _tokenId) override public view returns (string memory) {
        return string(abi.encodePacked(baseTokenURI(), Strings.toString(_tokenId),".json"));
    }

    /**
     * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator)
        override
        public
        view
        returns (bool)
    {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    /**
     * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
     */
    function _msgSender()
        internal
        override
        view
        returns (address sender)
    {
        return ContextMixin.msgSender();
    }
}