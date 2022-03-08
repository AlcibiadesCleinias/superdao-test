// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol";
import "./IGoldSilverBronzeNft.sol";


/**
* @title Treasuries Dao
* @dev The contract and its logic are designed to be deployed via deploy of
* @dev appropriate Nft.
* @dev
* @dev I decided to use list indexes as nft type identifiers (treasury kinds).
* @dev Thus, gold, silver, bronze supposed to be as 0, 1, 2.
* @dev On success withdraw dao reset votes in Nft.
*/
contract GoldSilverBronzeTreasuriesDao is Ownable {
    IGoldSilverBronzeNft private goldSilverBronzeNftContract;
    uint16 private _acceptWithdrawPercentageBound = 66;

    mapping (uint16 => uint256) public treasuryToBalance;
    mapping (uint16 => address) public treasuryToWithdrawAddress;

    constructor (address _goldSilverBronzeNft) public Ownable() {
        goldSilverBronzeNftContract = IGoldSilverBronzeNft(_goldSilverBronzeNft);
    }

    // function createTreasury(uint16 nftType) external {
    //     // todo: deprecate the function coz no needs?
    //     require(treasuryToBalance[nftType] == 0, "treasury already created and has coins on a balance");
    // }

    function sendToTreasury(uint16 treasuryId) external payable {
        treasuryToBalance[treasuryId] += msg.value;
    }

    /// @dev We suppose you pass the right parameter tokenTypeToTokenIds that you you check yourself
    /// @dev via GoldSilverBronzeNft on frontend before.
    /// @dev Thus, we optimise gas consumption here.
    function createWithdrawRequest(uint16 treasuryId, uint256 tokenTypeToTokenIdsId, address to) external {
        require(treasuryToWithdrawAddress[treasuryId] == address(0), "already pending withdrawal");
        uint256 tokenId = goldSilverBronzeNftContract.tokenTypeToTokenIds(treasuryId, tokenTypeToTokenIdsId);
        require(goldSilverBronzeNftContract.ownerOf(tokenId) == msg.sender, "msg sender is not token owner");
        treasuryToWithdrawAddress[treasuryId] = to;
        // todo: emit event
    }

    function withdrawTreasury(uint16 treasuryId) external {
        address _to = treasuryToWithdrawAddress[treasuryId];
        require(_to != address(0), "withdraw request was not created for treasury");

        uint256 treasuryTokens = goldSilverBronzeNftContract.mintedTokensOfType(treasuryId);
        uint256 approvals = 0;
        for (uint256 i = 0; i < treasuryTokens; i++) {
            uint256 tokenId = goldSilverBronzeNftContract.tokenTypeToTokenIds(treasuryId, i);
            if (goldSilverBronzeNftContract.tokenIdToVoteFor(tokenId) == true) {
                goldSilverBronzeNftContract.setVoteFor(tokenId, false);
                approvals += 1;
            }
        }

        require(approvals * 100 / treasuryTokens >= _acceptWithdrawPercentageBound, "no majority acceptance");
        payable(_to).transfer(treasuryToBalance[treasuryId]);
        treasuryToBalance[treasuryId] = 0;
        treasuryToWithdrawAddress[treasuryId] = address(0);
    }
}
