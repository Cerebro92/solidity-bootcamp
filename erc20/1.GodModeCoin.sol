// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GDCToken is ERC20 {
    address private godAddress;

    constructor(uint256 initialSupply) ERC20("GodCoin", "GDC") {
        _mint(msg.sender, initialSupply);
        godAddress = msg.sender;
    }

    modifier onlyGod() {
        require(msg.sender == godAddress, "Allowed only from God address");
        _;
    }

    /** Creates `amount` tokens and assigns them to `receipt`, increasing
     * the total supply.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function mintTokensToAddress(address recipient, uint256 amount)
        public
        onlyGod
        returns (bool)
    {
        _mint(recipient, amount);
        return true;
    }

    /**
     * Destroys `amount` tokens from `target`, reducing the
     * total supply.
     *
     * Requirements:
     *
     * - `target` cannot be the zero address.
     * - `target` must have at least `amount` tokens.
     */
    function reduceTokensAtAddress(address target, uint256 amount)
        public
        onlyGod
        returns (bool)
    {
        _burn(target, amount);
        return true;
    }

    /**
     * Moves all tokens from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     */
    function authoritativeTransferFrom(address from, address to)
        public
        onlyGod
        returns (bool)
    {
        uint256 amount = balanceOf(from);
        _transfer(from, to, amount);
        return true;
    }
}
