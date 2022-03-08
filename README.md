# superdao-test
Test hiring task from [SuperDAO](https://www.notion.so/superdao/Jobs-at-Superdao-d8b6b7599cc243a9b27f8b63e0c8e2bb).
> aka classic solution

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
This is a classic solution. Thus, I do not abuse Erc721 approve logic for DAO purpose (for abuse logic check `master` branch).
I delegate withdrawal approve to special methods in Erc721 (Nft), i.e. `setVoteFor` method.
The purpose is to be able to reset "vote" on token transferring.

My solution is without withdraw cancelling since `достаточно написать только тот функционал, который описан в данном задании`.

## TL;DR
1. Send eth to treasury
2. Create withdraw request to address
3. On your Nft vote for withdraw
4. Withdraw via treasury contract

## Feature
- When NFT is transferred, vote is removed
- One withdraw request per treasury at one time

## Test User Flow
- Deploy Nft contract, thus you deploy treasury contract as well, for address check event `LogDaoAddress`
- Nft contract owner mints Nft token for a user
- A user send eth to treasury contract
- A user creates withdraw request via `createWithdrawRequest` where he proves his ability to create the request by providing special token index
in `_tokenTypeToTokenIds` of Nft contract (for gas optimisation I do not leave the method coz it is alway could be done with frontend, thus, in contract (aka in chain) you merely prove your values without computations in chain).
- A user send withdrawTreasury if he believes that 2/3 acceptance accomplished (the same logic: it merely could be checked vie calls on frontend). On success contract removes approve for the treasury contract.


### Not standart to Erc721 updates:
- `mapping (uint256 => uint256[]) private _tokenTypeToTokenIds` to spot mapping between treasury type and Erc721 tokenId in treasury contract.
- `tokenTypeToTokenIds` as a helper method
- mapping to store votes
- method to set votes
- override `transferFrom`

# Notes
- I beleive there no need in safe math in the current situation, it is only test solution and on sol. 8+ safemath exist.
- I left docstrings and comment in contracts as well
- I used Remix IDE, thus repos structure is so one

