// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SimpleNFT is ERC721 {
    address public manager;
    uint256 public tokenSupply = 1;
    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant PRICE = 0.001 ether;

    constructor() ERC721("Black & White", "BNW") {
        manager = msg.sender;
    }

    modifier onlyManager() {
        require(manager == msg.sender, "Caller is not the manager");
        _;
    }

    function mint() external payable {
        require(tokenSupply <= MAX_SUPPLY, "supply exhausted");
        require(msg.value == PRICE, "incorrect fund received");

        _mint(msg.sender, tokenSupply);
        tokenSupply++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmRKoQ8oQJo1Z18ijQowqqB582R2acounQEoARipiPtj9p/";
    }

    function viewBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdraw() external onlyManager {
        payable(msg.sender).transfer(address(this).balance);
    }
}
