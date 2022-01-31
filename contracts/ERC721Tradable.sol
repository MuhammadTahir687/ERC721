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
     uint256 private _maxSupply=100;
     uint256 private _maxPresaleSupply=25;
     address public proxyRegistryAddress;

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

    function PresalePrice(uint256  Presale_Price ) public  onlyOwner {
         _presalePrice = Presale_Price; 
    }
    function MainsalePrice(uint256  Mainsale_Price ) public  onlyOwner {
         _price = Mainsale_Price; 
    }
  function MainsaleSupply(uint256  Mainsale_Supply ) public  onlyOwner {
         _maxSupply = Mainsale_Supply; 
    }
     function PresaleSupply(uint256  Presale_Supply ) public  onlyOwner {
         _presalePrice = Presale_Supply; 
    }

    function mintTo(address _to ) payable public virtual {
        require(balanceOf(msg.sender) <=9,"Only eight NFT Mint Per Address");
          require(totalSupply() <= _maxSupply,"All Tokens Mint");
          require(msg.value >= _price,"Not Enough Ether");
          payable(0x84dDA0d57Bf4144f669542e0DD0F6B21389300Af).transfer(msg.value);
         _tokenIdTracker.increment();
           _mint(_to, _tokenIdTracker.current());
    }
    
    function Presale(address _to) payable public virtual{
         require(balanceOf(msg.sender) <=1,"Only Two NFT Mint Per Address");
         require(totalSupply() <= _maxPresaleSupply);
         require(msg.value >= _presalePrice,"Not Enough Price to mint");
         payable(0x84dDA0d57Bf4144f669542e0DD0F6B21389300Af).transfer(msg.value);
        _tokenIdTracker.increment();
        _mint(_to, _tokenIdTracker.current());
    }

    function OwnerPresale(address _to) public onlyOwner{
         require(totalSupply() <= _maxPresaleSupply);
        _tokenIdTracker.increment();
        _mint(_to, _tokenIdTracker.current());
    }

     function OwnerMainsale(address _to) public onlyOwner{
         require(totalSupply() <= _maxSupply);
        _tokenIdTracker.increment();
        _mint(_to, _tokenIdTracker.current());
    }

    function baseTokenURI() virtual public view returns (string memory){
        return _baseURI();
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