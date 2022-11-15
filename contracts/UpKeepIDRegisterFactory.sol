// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// Link token : 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
// Registrar Address: 0xDb8e8e2ccb5C033938736aa89Fe4fa1eDfD15a1d
// Registry address: 0x02777053d6764996e594c3E88AF1D58D5363a2e6	

// UpkeepIDConsumerExample.sol imports functions from both ./AutomationRegistryInterface1_2.sol and
// ./interfaces/LinkTokenInterface.sol
//v0.1
import {AutomationRegistryInterface, State, Config} from "@chainlink/contracts/src/v0.8/interfaces/AutomationRegistryInterface1_2.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "./AutomateGrids.sol";

/**
* THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
* THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
* DO NOT USE THIS CODE IN PRODUCTION.
*/

interface KeeperRegistrarInterface {
  function register(
    string memory name,
    bytes calldata encryptedEmail,
    address upkeepContract,
    uint32 gasLimit,
    address adminAddress,
    bytes calldata checkData,
    uint96 amount,
    uint8 source,
    address sender
  ) external;
}

contract UpKeepIDRegisterFactory {
  LinkTokenInterface public immutable i_link;
  address public immutable registrar;
  AutomationRegistryInterface public immutable i_registry;
  bytes4 registerSig = KeeperRegistrarInterface.register.selector;
  
  address public ownerOfGrids;
  uint public numberOfAutomateGrids;
  address[] public AutomateGridsList;
  uint256[] public ids;

  constructor(
    LinkTokenInterface _link,
    address _registrar,
    AutomationRegistryInterface _registry
  ) {
    ownerOfGrids = msg.sender;
    i_link = _link;
    registrar = _registrar;
    i_registry = _registry;
  }

  function registerAndPredictID(
    string memory name,    
    address upkeepContract,    
    address adminAddress       
  ) public {
    (State memory state, Config memory _c, address[] memory _k) = i_registry.getState();
    uint256 oldNonce = state.nonce;
    bytes memory payload = abi.encode(
      name,
      '0x',
      upkeepContract,
      999999,
      adminAddress,
      'ox',
      5 ether,
      0,
      address(this)
    );
    
    i_link.transferAndCall(registrar, 5 ether, bytes.concat(registerSig, payload));
    (state, _c, _k) = i_registry.getState();
    uint256 newNonce = state.nonce;
    if (newNonce == oldNonce + 1) {
      uint256 upkeepID = uint256(
        keccak256(abi.encodePacked(blockhash(block.number - 1), address(i_registry), uint32(oldNonce)))
      );
      ids.push(upkeepID);
      // DEV - Use the upkeepID however you see fit
    } else {
      revert("auto-approve disabled");
    }
  }

  function checkAndResolve(
    string memory name,     
    address spotBotGrid    
    )public {
      //require link balance in this contract
    bool canManageNewGrid = checkLastAutomateGridState();
    if(canManageNewGrid){
      AutomateGrids lastAutomateGrid = AutomateGrids(AutomateGridsList[AutomateGridsList.length-1]);
      lastAutomateGrid.pushNewGrid(spotBotGrid);
      numberOfAutomateGrids++;
    }else{
      address newAutomatedGrids = address(new AutomateGrids(spotBotGrid, address(this)));
      AutomateGridsList.push(newAutomatedGrids);
      registerAndPredictID(
        name,
        newAutomatedGrids,
        ownerOfGrids
      );
      numberOfAutomateGrids++;

    }
  }


  //check if lastAutomatedGrid is open to manage a new gridbot
  function checkLastAutomateGridState() public view returns(bool){
    bool canManageNewGrid;
    if(numberOfAutomateGrids >= 1){
      AutomateGrids lastAutomateGrid = AutomateGrids(AutomateGridsList[AutomateGridsList.length-1]);

      uint maxGridMange = lastAutomateGrid.getMaxGridsUnderManage();
      uint length = lastAutomateGrid.getLength();

      if(length<maxGridMange){
        canManageNewGrid=true;
      }
    }
    return canManageNewGrid;
  }

  function withdrawLinks()public {   
    i_link.transfer(msg.sender, i_link.balanceOf(address(this)));
  }

  function cancelKeepAndGiveBackFunds(uint id, address to)public {
    i_registry.cancelUpkeep(id);
    i_registry.withdrawFunds(id, to);
  }

  // ------------------------------------------ INTERNALS ------------------------------------------

  // function cancelUpkeep(uint256 id) external;
  //withdrawFunds 
}