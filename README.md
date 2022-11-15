# chainlink-hack-2022-contracts
Smart Contracts for chainlink hackaton 2022

## Notion Brain project (this this is a mess )
https://duckdev.notion.site/ChainLink-Hack-64dc8c61986b44b0851bfda05175f9d4

- Real repo of work: https://github.com/LeandroCDN/chainlink-hack-2022-contracts


# Grid Bot On Chain
A simple grid bot on chain, against uniswap v3 contracts.


## Technologies used

->**ChainLink Services**:
  
   ~~ **Keepers** : *Used to create new registers to automations. Each five gridsBots is registered a new automations.*   
   
   ~~ **Automatizations** : *To check if a swap is necessary, and to do it.* 
   
   ~~ **DataFeeds** : *Used to calculate prices in create a new grid, and compare prices to check if necessary a swap.*
   
 
 
 -> OpenZeppelin libraries
 
 -> Uniswap V3 contracs
 
 -> Hardhat
  

## Contrac cycle

 1- Create a new grid (This is a new contract), this cost 1link+1matic (all in matic), need put a price of buy, price of sell, and token to buy/sell.

 2- Your recived a nft.

 3- Create a grid if create a new contrac, need put the token to buy and sell for usd(usd is standar)

 4- Lastly, fund your grid bot contract, with usdc(uses ux to make this).

 5- The bot should be working, at the moment every swap is a all in. If you withdraw you can receive one of the tokens, usdc how standard, or the token you selected in the creation. This depend of state of your contract.

## Technical aspect of contracts


**GridBotFactory**: A Contract create new contract grids, calculate cost using chainlink Feeds (calculate 1Link in Matic + 1 Matic) and mint a nft to representante the position.
In the buy of grid, a automatic system, make a swap for 1 link and send this token to UpKeepIDRegisterFactory contract.

**UpKeepIDRegisterFactory** : Register new keeper (cost 5links),  this keeper can manage five grid bot, from differents users.
Each five Grids, make a new keepers with five links.

**NFTGridData** : It is the simple way to abstract all the complex logic for the users. Each bot is linked to an nft id.
The owner of this ID is the owner of the bot contract and its liquidity. If you transfer the nft, you transfer your bot ownership and liquidity

**AutomateGrids** : This contract is created by UpKeepIDRegisterFactory, your function is manage grid-bot positions, can manage five or less.
This contract use automations, to check state of grid bot, run sales and buys if is nesesari, this is posible thanks to chainlink.

**SpotBotGrid**: This contract is created by GridBotFactory.
This contract uses uniswap v3 to conect swaps and chain link to know if nesesari a swap or not, this state is used by AutomateGrids to make automatic swaps under 
simple comparations to buyPrice against chainlink data feed price.


## Poligon testnet contracts

 - nftGridData Address: 0xE8B0c5d509050D26481FA75767558E6740f84C43
 - upKeepIDRegisterFactory Address: 0x358395de7e042a9707DAb7050DF137D422f1ADBc
 - GridBotFactory Address: 0xD609CDD36e9C3A153d695c3a2d014CBf651CB071

Use scan to read state and search list of bot address in GridBotFactory.

If nesesary can use a faucet to claim usdc mock token uses in testnet

 Faucet address: Under construction
 Function:---

 My social networks @LeanLabiano. 
