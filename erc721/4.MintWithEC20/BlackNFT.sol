// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./BlackToken.sol";

contract ComplexNFT is ERC721 {
    BlackToken blackToken;
    address public manager;
    uint256 public tokenSupply = 1;
    uint256 public constant MAX_SUPPLY = 10;

    constructor(address _tokenAddress) ERC721("Black & White", "BNW") {
        blackToken = BlackToken(_tokenAddress);
    }

    function mint() external payable {
        require(tokenSupply <= MAX_SUPPLY, "supply exhausted");
        blackToken.transferFrom(msg.sender, address(this), 10);

        _mint(msg.sender, tokenSupply);
        tokenSupply++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmRKoQ8oQJo1Z18ijQowqqB582R2acounQEoARipiPtj9p/";
    }
}
