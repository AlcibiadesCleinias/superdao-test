// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol";

/**
* @title Simple NFT with additional logic around NFT type.
* @dev The order of token id represents type of NFT:
* @dev gold, silver, bronze.
*
* @dev I left a possibility to easily increase number of types.
* @dev I manually added tokenTypeToTokenIds method coz simple public
* @dev fails silently on idx error.
*/
contract GoldSilverBronzeNft is Ownable, ERC721 {
    uint16 _maxTokensPerType = 20;
    uint16 _tokenTypes = 3;

    mapping (uint256 => uint256[]) private _tokenTypeToTokenIds;
    using Counters for Counters.Counter;

    constructor() public ERC721("SuperdDaoTypedNftTest", "SDTNT") {}

    Counters.Counter private _tokenIds;

    function mint(address to, string memory tokenURI, uint16 typeId) onlyOwner
        public
        returns (uint256)
    {
        require(typeId < _tokenTypes, "This type id is not allowed");
        require(_tokenTypeToTokenIds[typeId].length < _maxTokensPerType, "Only several tokens allowed per type.");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _tokenTypeToTokenIds[typeId].push(newItemId);
        _mint(to, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function mintedTokensOfType(uint16 typeId) view external returns (uint256) {
        return _tokenTypeToTokenIds[typeId].length;
    }

    function tokenTypeToTokenIds(uint256 _tokenType, uint256 _tokenTypeId) external view returns (uint256) {
        uint256[] memory tokenIdx = _tokenTypeToTokenIds[_tokenType];
        require(_tokenTypeId < tokenIdx.length, "the token type id does not exist");
        return tokenIdx[_tokenTypeId];
    }
}
