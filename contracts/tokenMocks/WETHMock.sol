// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETHMock is ERC20 {
    constructor() ERC20("WETH Mock", "WETH") {
        _mint(msg.sender, 122373863 * 10 ** decimals());
    }
    //@Gridbot LeanLabiano
}