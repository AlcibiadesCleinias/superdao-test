// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol";
import "./GoldSilverBronzeTreasuriesDao.sol";

/**
* @title NFT with Integrated Treasury Dao Logic.
* @dev The order of token id represents type of NFT:
* @dev gold, silver, bronze.
*
* @dev DAO is deployed on Nft deploy. Thus Nft provide Dao address
* @dev that now can reset votes on success or on implemented logic
* @dev in Dao contract.
* @dev I left a possibility to easily increase number of types.
* @dev I manually added tokenTypeToTokenIds method coz simple public
* @dev fails silently on idx error.
*/
contract GoldSilverBronzeNft is Ownable, ERC721 {
    address public dao;
    uint16 _maxTokensPerType = 2;  // todo
    uint16 _tokenTypes = 3;
    using Counters for Counters.Counter;

    event LogDaoAddress(address newDao);  // for testing

    mapping (uint256 => uint256[]) private _tokenTypeToTokenIds;
    mapping (uint256 => bool) public tokenIdToVoteFor;

    constructor() public ERC721("SuperdDaoTypedNftTest", "SDTNT") {
        GoldSilverBronzeTreasuriesDao _dao = new GoldSilverBronzeTreasuriesDao(address(this));
        dao = address(_dao);
        emit LogDaoAddress(dao);
    }

    Counters.Counter private _tokenIds;

    function transferFrom(address from, address to, uint256 tokenId) public override {
        tokenIdToVoteFor[tokenId] = false;
        ERC721.transferFrom(from, to, tokenId);
    }

    function setVoteFor(uint256 tokenId, bool vote) external {
        require(msg.sender == ERC721.ownerOf(tokenId) || msg.sender == dao, "not a token owner or dao");
        require(vote != tokenIdToVoteFor[tokenId], "vote is the same");
        tokenIdToVoteFor[tokenId] = vote;
    }

    function mint(address to, string memory tokenURI, uint16 typeId) onlyOwner
        public
        returns (uint256)
    {
        require(typeId < _tokenTypes, "this type id is not allowed");
        require(_tokenTypeToTokenIds[typeId].length < _maxTokensPerType, "only several tokens allowed per type.");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _tokenTypeToTokenIds[typeId].push(newItemId);
        _mint(to, newItemId);
        _setTokenURI(newItemId, tokenURI);
        tokenIdToVoteFor[newItemId] = false;

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
