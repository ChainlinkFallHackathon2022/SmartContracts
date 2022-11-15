// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISpotGrid {
  function buy() external;
  function sell() external;

  function getBuyPrice()external view returns(uint);
  function getSellPrice()external view returns(uint);

  //if return true => waitingBuy |  if return false => waitingSell
  function getBalanceStable() external view returns(uint);
  function getBalanceTradeableToken() external view returns(uint);
  function getTradeableTokenAddress() external view returns(address);

   function canBuy() external view returns(bool);
   function canSell() external view returns(bool);

   function changeOwnerBot(address newOwner) external;
}