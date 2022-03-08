// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;


interface IGoldSilverBronzeNft {
    function ownerOf(uint256 _tokenId) external view returns (address);
    function approve(address _approved, uint256 _tokenId) external payable;
    function getApproved(uint256 tokenId) external view returns (address);
    function mintedTokensOfType(uint16 typeId) view external returns (uint256);
    function tokenTypeToTokenIds(uint256 _tokenType, uint256 _tokenTypeId) external view returns (uint256);
    function tokenTypeToCounterFor(uint256) external returns(uint256);
    function tokenIdToVoteFor(uint256) external returns(bool);
    function setVoteFor(uint256 tokenId, bool vote) external;
}
