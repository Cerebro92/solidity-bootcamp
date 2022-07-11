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

    /** Creates `1000` tokens and assigns them to caller, increasing
     * the total supply.
     *
     * Requirements:
     *
     * - atleast 1 ether payment required.
     * - `totalSupply` should not exceed 1 million.
     */
    function mint() public payable returns (bool) {
        require(
            msg.value >= 1 ether,
            "Atleast 1 ether required to mint 1000 tokens"
        );
        require(
            totalSupply() + 1000 * 10**18 < 1000000 * 10**18,
            "total supply limit exceeded"
        );
        _mint(msg.sender, 1000 * 10**18);
        return true;
    }

    /** Withdraw ethereum from contract to the owner of contract.
     */
    function withdraw() public returns (bool) {
        payable(owner).transfer(address(this).balance);
        return true;
    }
}
