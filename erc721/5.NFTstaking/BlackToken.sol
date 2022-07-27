// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BlackToken is ERC20 {
    constructor() ERC20("BlackCoin", "BLACK") {}

    function mint(uint256 amount) external {
        _mint(_msgSender(), amount);
    }
}
