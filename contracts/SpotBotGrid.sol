// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* 
* SuperAdminRole :nft -> changeOwner
* House Role: Pauses, and give back funds

* Especial Function: nft id sistem - 
*/

//for wrapped tokens
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./utils/Swap.sol";

/*
*  Dev @LeanLabiano (youtube chanel ;)
*  First objetive: 
    ALL IN automte trading bot.
*  Two points : BuyPoint (uses all usdc in this contract) and SellPoint(uses all asset in this contract)
*/

//v0.1
contract SpotBotGrid is AccessControl, Swap {

  struct userData{
    uint buyPrice; //In 8 decimals! For chainlink datafeed
    uint sellPrice; //In 8 decimals!
    uint totalFundAmount;
    address admin;
  }
  bool public paused;
  uint id;
  uint public totalSwaps;

  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  bytes32 public constant HOUSE_ROLE = keccak256("HOUSE_ROLE");
  address public house; //NEED HARDCORE ADDRESS

  IERC20 stableCoin; // Need One Stable!
  IERC20 tradeableToken;
  IERC721 nft = IERC721(0xE8B0c5d509050D26481FA75767558E6740f84C43); //PUT AND ADDRESS HERE!

  AggregatorV3Interface dataFeed;
  userData data;

  event BUY(uint balance, address to,address tokenOut, address tokenIn);
  event SELL(address to,address tokenOut, address tokenIn);

  //swap router 0xE592427A0AEce92De3Edee1F18E0157C05861564
  constructor(
    address stableCoin_, 
    address tradeableToken_, 
    address dataFeed_,
    uint buyPrice_,
    uint sellPrice_,
    address ownerOfBot_,
    address _swapRouter,
    uint _id
  ) Swap(_swapRouter){
    stableCoin = IERC20(stableCoin_);
    tradeableToken = IERC20(tradeableToken_);
    dataFeed = AggregatorV3Interface(dataFeed_);
    data = userData(buyPrice_, sellPrice_, 0, ownerOfBot_);
    id = _id;
    //_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(ADMIN_ROLE, address(nft) );
    _grantRole(HOUSE_ROLE, house );
  }

  // ------------------------------------ PUBLIC FUNCTIONS ------------------------------------
  function buy() public {
    uint balance = getBalanceStable();
    require(balance > 0, "Next movement is sell, dont but now");
    bool canExec = _getPrice() <= getBuyPrice();
    require(canExec, "Over price to buy");
    if(data.totalFundAmount == 0){
      data.totalFundAmount = balance;
    }
    totalSwaps++;
    swapExactInputSingle(balance, address(this), address(stableCoin), address(tradeableToken));
    emit BUY(balance, address(this), address(stableCoin), address(tradeableToken));
  }
  
  function sell() public  {
    uint balance = getBalanceStable();
    require(balance <= 0, "Next movement is sell, dont but now");
    bool canExec = _getPrice() >= getSellPrice();
    require(canExec, "Under price to sell");
    totalSwaps++;
    swapExactInputSingle(getBalanceTradeableToken(), address(this), address(tradeableToken), address(stableCoin));
    emit SELL( address(this), address(stableCoin), address(tradeableToken));
  }

  function editPriceToBuy(uint newBuyPrice) public {
    require(nft.ownerOf(id) == msg.sender, "Only owner of id can edit prices");
    data.buyPrice = newBuyPrice;
  }
  function editPriceTosell(uint newSellPrice) public {
    require(nft.ownerOf(id) == msg.sender, "Only owner of id can edit prices");
    data.sellPrice = newSellPrice;
  }

  function withdraw() public {
    require(nft.ownerOf(id) == msg.sender, "Only owner of id can withdraw funds");
    uint balanceStable = getBalanceStable();
    uint balanceTradeableToken = getBalanceTradeableToken();

    if(balanceStable>0){
      stableCoin.transfer(data.admin, balanceStable);
    }
    if(balanceTradeableToken>0){
      tradeableToken.transfer(data.admin, balanceTradeableToken);
    }
  }
  
  function togglePause() public onlyRole(HOUSE_ROLE){
    paused = !paused;
  }

  function changeOwnerBot(address newOwner) external onlyRole(ADMIN_ROLE){
    data.admin = newOwner;
  }

  function fundGrid(uint amount) public{
    stableCoin.transferFrom(msg.sender, address(this), amount);
    data.totalFundAmount += amount;
  }

  // ------------------------------------ VIEW FUNCTIONS ------------------------------------
  function getBuyPrice()public view returns(uint){
    return data.buyPrice;
  }
  function getSellPrice()public view returns(uint){
    return data.sellPrice;
  }

  //if return true => waitingBuy |  if return false => waitingSell
  function getBalanceStable() public view returns(uint){
    return stableCoin.balanceOf(address(this));
  }
  function getBalanceTradeableToken() public view returns(uint){
    return tradeableToken.balanceOf(address(this));
  }

  function canBuy() public view returns(bool){
    uint balance = getBalanceStable();
    bool canExec = false;
    if(balance > 0){
     canExec = _getPrice() <= getBuyPrice();
    }
    
    return canExec;
  }

  function canSell() public view returns(bool){
    uint balance = getBalanceStable();
    bool canExec = false;
    if(balance <= 0){
      canExec = _getPrice() >= getSellPrice();
    }
    
    return canExec;
  }

  function owner()public view returns(address){
    return data.admin;
  }
  function getTradeableTokenAddress() public view returns(address){
    return address(tradeableToken);
  }

  function gridProfitPerSell() public view returns(uint){
    uint buyP = data.buyPrice;
    uint sellP = data.sellPrice;
    require(sellP>buyP);
    return ((sellP-buyP)*100)/buyP;
  }
  function gridTotalProfit() public view returns(int profit){
    uint balance = getBalanceStable();
    uint initialBalance =data.totalFundAmount;

    if(balance<0){
      balance = getBalanceTradeableToken();
      balance = balance * (_getPrice() * 10000000000);
    }
    if(initialBalance>balance){
      profit = int(((balance - initialBalance)*100/initialBalance));
    }else{
      profit = (int(balance - initialBalance)*100/int(initialBalance));
    }

  }


  // ------------------ PRIVATE FUNCTIONS ------------------ -> public for tests
  function _getPrice() public view returns (uint){
    (,int price,,,) = dataFeed.latestRoundData();
    return uint(price);
  }

}