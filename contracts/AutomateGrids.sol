// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

// Registrar Address: 0xDb8e8e2ccb5C033938736aa89Fe4fa1eDfD15a1d //mumbai!
// Registry address: 0x02777053d6764996e594c3E88AF1D58D5363a2e6	 //mumbai!

import "@openzeppelin/contracts/access/AccessControl.sol";
import {AutomationRegistryInterface, State, Config} from "@chainlink/contracts/src/v0.8/interfaces/AutomationRegistryInterface1_2.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol"; 
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import "./interfaces/ISpotGrid.sol";

//v0.1
contract AutomateGrids is AccessControl,  AutomationCompatible {
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  address[] public listOfGrid;
  uint public maxGridMange = 5;

  constructor(address grid, address adminOfPush) {
    listOfGrid.push(grid);
    _grantRole(DEFAULT_ADMIN_ROLE, adminOfPush);
    _grantRole(ADMIN_ROLE, adminOfPush);
  }

  function pushNewGrid(address spotBotGrid) public {
    require(listOfGrid.length <= maxGridMange, "Max of grids" );
    listOfGrid.push(spotBotGrid);
  }

  function checkUpkeep(bytes calldata /*checkData*/)
    external 
    view 
    override
    returns (bool upkeepNeeded, bytes memory performData)
  {
    uint[5] memory action; //0 nathing to do - 1 buy - 2sell

    for (uint i; i < listOfGrid.length; i++){
      ISpotGrid grid = ISpotGrid(listOfGrid[i]);
      
      bool buy = grid.canBuy();
      bool sell = grid.canSell();
      if(buy){
          action[i] = 1;
          upkeepNeeded = true;
      }
      if(sell){
          action[i] = 2;
          upkeepNeeded = true;
      }
    }
    performData = abi.encode(action);
    return(upkeepNeeded,performData);
  }

  function performUpkeep(bytes calldata _performData) external override{
    (uint[5] memory action) = abi.decode(_performData,( uint[5]));

    for (uint i; i < listOfGrid.length; i++){
      ISpotGrid grid = ISpotGrid(listOfGrid[i]);

      if(action[i] == 1){
        grid.buy();
      }
      
      if(action[i] == 2){
        grid.sell();
      }
    }
  }
  function getLength() public view returns(uint){
    return listOfGrid.length;
  }
  function getMaxGridsUnderManage() public view returns(uint){
    return maxGridMange;
  }
} 