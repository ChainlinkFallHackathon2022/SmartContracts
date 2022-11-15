// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // to get price link
import "./SpotBotGrid.sol";
import "./UpKeepIDRegisterFactory.sol";
import "./interfaces/INFTGridData.sol";

interface WMatic is IERC20 {
  function deposit() external payable;
}

//v0.1.001
contract GridBotFactory  is Swap{
  
  uint public totalGrids;
  address[] public listOfAllGrid;
  struct userData{
    address gridBotAddress;
    uint nftID;    
  }

  mapping(address => userData[]) public listOfGridsPerUser;
  address public linkToken = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
  
  INFTGridData nftGrid;
  AggregatorV3Interface maticUsdFeed;
  AggregatorV3Interface linkUsdFeed = AggregatorV3Interface(0x12162c3E810393dEC01362aBf156D7ecf6159528);
  WMatic public wmatic = WMatic(0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889); //mumbai
  UpKeepIDRegisterFactory registerKeeps;
  IERC20 public currency;


  constructor(address _NFTGridData, address _currency, address _registerKeeps) Swap(0xE592427A0AEce92De3Edee1F18E0157C05861564){
    currency = IERC20(_currency);
    nftGrid = INFTGridData(_NFTGridData);
    registerKeeps = UpKeepIDRegisterFactory(_registerKeeps);
    
  }

  function factoryNewGrid(
    string memory name,
    string memory uri_,
    address tradeableToken,
    uint buyPrice,
    uint sellPrice,
    address owner
  ) public payable {
    require(msg.value >= (calculatePriceInMatic() / 1000), "Need More matic");
    wmatic.deposit{ value: msg.value }();
    require(wmatic.balanceOf(address(this)) > 0, "Require more Wmatic");
    swapExactInputSingleMatic(wmatic.balanceOf(address(this)),address(registerKeeps),address(wmatic), linkToken);

    uint id = nftGrid.getCurrentId();
    address newGrid = _newGrid(
       tradeableToken,
       buyPrice,
       sellPrice, 
       owner,
       id
    );   

    registerKeeps.checkAndResolve(name, newGrid );
    nftGrid.safeMint(owner, uri_, newGrid);
    
    _updateData(newGrid,id,owner);
  }

  function changeOwnerOfNFT(address newOwner)public{
    nftGrid.transferOwnership(newOwner);
  }

  // --------------------------------- VIEW FUNCTIONS ---------------------------------

  function getNFTid() public view returns(uint){
    return nftGrid.getCurrentId();
  }

  function getTotalNumberOfGrid(address _user)public view returns(uint){
    return listOfGridsPerUser[_user].length;
  }

  function getGridDataPerUser(
    address _user, 
    uint index
  )public view returns(
    address gridAddress,
    uint nftID,
    uint buyPrice,
    uint sellPrice,
    address tradeableToken
  ){
    SpotBotGrid grid = SpotBotGrid(listOfGridsPerUser[_user][index].gridBotAddress);
    nftID = listOfGridsPerUser[_user][index].nftID;
    buyPrice = grid.getBuyPrice();
    sellPrice = grid.getSellPrice();

    return(address(grid), nftID, buyPrice, sellPrice, grid.getTradeableTokenAddress());
  }
  function getDataPerGrid(SpotBotGrid grid) public view returns(address, uint){
    address owner = grid.owner();
    uint lengt = getTotalNumberOfGrid(owner);
    uint index;
    if(lengt > 1){
      for(uint i; i <lengt; i++){
       if(listOfGridsPerUser[owner][i].gridBotAddress ==address(grid)) {
        index = i;
       }
      }
    }
    return (owner,index);
  }

  // --------------------------------- INTERNAL FUNCTIONS ---------------------------------

  function _newGrid(address _tradeableToken, uint _buyPrice, uint _sellPrice, address _owner, uint id) public returns(address){
    address newGrid = address(new SpotBotGrid(
      address(currency),
      _tradeableToken,
      0x007A22900a3B98143368Bd5906f8E17e9867581b, // Datafeed btc/usd mumbai
      _buyPrice,
      _sellPrice,
      _owner,
      0xE592427A0AEce92De3Edee1F18E0157C05861564, //swap router, can be constant in mainet
      id
    ));
    return newGrid;
  }

  function _updateData(address _grid, uint _id,address _owner) public {
    listOfAllGrid.push(_grid);
    totalGrids++;
    listOfGridsPerUser[_owner].push(userData(_grid, _id));
  }


  function calculatePriceInMatic() public view returns(uint){
    uint linkPrice = _getPrice(linkUsdFeed);

    return linkPrice + 1 ether;
  }

  function _getPrice(AggregatorV3Interface dataFeed) public view returns (uint){
    (,int price,,,) = dataFeed.latestRoundData();
    return uint(price);
  }
}