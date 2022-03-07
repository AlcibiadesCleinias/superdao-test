// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol";
import "./IGoldSilverBronzeNft.sol";


/**
* @title Treasuries DAO.
* @dev I decided to use list indexes as nft type identifiers (treasury kinds).
* @dev Thus, gold, silver, bronze supposed to be as 0, 1, 2.
* @dev
* @dev Why I put in Erc721 approve method?
* @dev Case:
* @dev 1. Withdraw approved by NFT owner in DAO contrac,
* @dev 2. Then the NFT owner transfer his NFT to someone.
* @dev What should we do?
* @dev I believe that in this case withdrawal approve should be deprecated.
* @dev The optimal way is to deligate deprecation to Nft specific, where approve removed on Nft transfered.
* @dev And to approve withdraw you merely need to approve nft for the dao contract below.
* @dev Via this trick we as well ban NFT owner to approve his NFT for transfer to smbdy
* @dev when nft owner particiate in dao withdraw process. On success withdraw contract sets nft approve
* @dev to 0 address.
* @dev PS. to have the ability to set approve NFT owner have to run once approveForAll
* @dev to the dao contract.
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

    function withdrawTreasury(uint16 treasuryId) external {  // safe?
        // check approved for all not needed, it should be explained on fronted
        // and approve for all method should be run ones per contract.
        address _to = treasuryToWithdrawAddress[treasuryId];
        require(_to != address(0), "withdraw request was not created for treasury");

        uint256 treasuryTokens = goldSilverBronzeNftContract.mintedTokensOfType(treasuryId);
        uint16 approvals = 0;
        for (uint256 i = 0; i < treasuryTokens; i++) {
            uint256 tokenId = goldSilverBronzeNftContract.tokenTypeToTokenIds(treasuryId, i);
            if (goldSilverBronzeNftContract.getApproved(tokenId) == address(this)) {
                approvals += 1;
                goldSilverBronzeNftContract.approve(address(0), tokenId);
            }
        }

        require(approvals * 100 / treasuryTokens >= _acceptWithdrawPercentageBound, "no majority acceptance");
        payable(_to).transfer(treasuryToBalance[treasuryId]);
        treasuryToBalance[treasuryId] = 0;
        treasuryToWithdrawAddress[treasuryId] = address(0);
    }
}
