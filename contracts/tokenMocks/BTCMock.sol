// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BTCMock is ERC20 {
    constructor() ERC20("BTC Mock", "BTC") {
        _mint(msg.sender, 19192425 * 10 ** decimals());
    }
    //@Gridbot LeanLabiano
}