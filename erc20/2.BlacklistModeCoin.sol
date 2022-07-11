// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GDCToken is ERC20 {
    address private owner;
    mapping(address => bool) private blacklistedAddresses;

    constructor(uint256 initialSupply) ERC20("GodCoin", "GDC") {
        _mint(msg.sender, initialSupply);
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Allowed contract owner");
        _;
    }

    function blacklistAddress(address account) public isOwner returns (bool) {
        blacklistedAddresses[account] = true;
        return true;
    }

    function unblacklistAddress(address account) public isOwner returns (bool) {
        blacklistedAddresses[account] = false;
        return true;
    }

    /**
     * Overloading hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 /* amount */
    ) internal view override {
        require(!blacklistedAddresses[to], "Recipient is blacklisted");
        require(!blacklistedAddresses[from], "Sender is blacklilsted");
    }
}
