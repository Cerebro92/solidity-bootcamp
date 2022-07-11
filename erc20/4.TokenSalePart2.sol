/*

Flow # 1
1. step#1 Buys token from contract and pays 1 ether. 
2. step#2 Allow contract to spend some tokens.


Flow # 2
1. User asks to buy tokens from contract
2. Contract check tokens present in its pool.
3. If available, transfer tokens and deduct balance.
4. If not avaiable, check other holders token balance (approved for spending by contract). if available, spend it + deposit ethers.
5. return

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error InsufficientBalance(uint256 available, uint256 required);

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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal view override {
        if (address(this) == to) {
            uint256 requiredEther = requireEthers(amount);
            if (address(this).balance <= requiredEther) {
                revert InsufficientBalance({
                    available: address(this).balance,
                    required: requiredEther
                });
            }
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (address(this) == to) {
            uint256 requiredEther = requireEthers(amount);
            payable(from).transfer(requiredEther);
        }
    }

    function requireEthers(uint256 amount) internal pure returns (uint256) {
        uint256 requiredEther = (0.5 * 10**18 * amount) / (1000 * 10**18);
        return requiredEther;
    }
}
