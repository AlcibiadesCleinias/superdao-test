# superdao-test
Test hiring task from [SuperDAO](https://www.notion.so/superdao/Jobs-at-Superdao-d8b6b7599cc243a9b27f8b63e0c8e2bb).

# Task Description [ru]
Нужно написать смарт-контракт для DAO членство которого определяется на основе NFT. 

Токен разделен на несколько типов: gold, silver, bronze. 

Каждый тип содержит не больше 20 токенов.

Администратор DAO может создать несколько общих счетов (treasury) доступных только одному из типов NFT. 
На один тип NFT может быть только один общий счет. 
На данный счет можно отправить ETH, но вывести средства можно, если 2/3 участников дадут разрешение.

Требуется написать безопасный смарт-контракт оптимизированный по газу. 
К коду нужно приложить описание своего решения.
Задание можно выполнить в remix и упростить некоторые моменты. 
Тесты писать не нужно.
Не нужно писать весь функционал DAO в традиционном его понимании, достаточно написать только тот функционал, который описан в данном задании.

# Solution
We have Erc721 contract with a lot of methods and strong logic - what if we can abuse such instrument?
Thus, in my solution I decide to deligate withdraw approve to Nft approve for the treasury contract 
(i.e. [contracts/GoldSilverBronzeTreasuriesDao.sol](contracts/GoldSilverBronzeTreasuriesDao.sol)).
My solution is without withdraw cancelling since `достаточно написать только тот функционал, который описан в данном задании`.

## TL;DR
1. Send eth to treasury
2. Create withdraw request to address
3. Approve Nft for contract (thus, you accept created  withdraw)
4. Withdraw

## Feature
- When NFT is transfered, withdrawal approve is removed
- When NFT is approved for someone (potential transfering) not for the treasury contract withdrawal approve is removed
- Reuse for Erc721 contract code
- One withdraw request per treasury at one time

## Test User Flow
- Deploy Nft contract
- Deploy treasury contract with address of Nft contract
- Nft contract owner mints Nft token for a user
- Nft user approves for all to treasury contract (now contract can change approve)
- A user send eth to treasury
- A user creates withdraw request via `createWithdrawRequest` where he proves his ability to create the request by providing special token index
in `_tokenTypeToTokenIds` of Nft contract (for gas optimisation I do not leave the method coz it is alway could be done with frontend, thus, in contract (aka in chain) you merely prove your values without computations in chain).
- A user send withdrawTreasury if he beleives that 2/3 acceptence accomplished (the same logic: it merely cpould be checked vie calls on frontend). On success contract removes approve for the treasury contract.


### Not standart to Erc721 updates:
- `mapping (uint256 => uint256[]) private _tokenTypeToTokenIds` to spot mapping between treasury type and Erc721 tokenId in treasury contract.
- `tokenTypeToTokenIds` as a helper method

# Notes
- I beleive there no need in safe math in the current situation, it is only test solution and on sol. 8+ safemath exist.
- I left docstrings and comment in contracts as well
- I used Remix IDE, thus repos structure is so one

