// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./BlackToken.sol";

contract BlackNFT is ERC721 {
    BlackToken blackToken;
    address public manager;
    uint256 public tokenSupply = 1;
    uint256 public constant MAX_SUPPLY = 10;
    mapping(uint256 => uint256) public stakePool;
    uint256 constant STAKE_WINDOW = 24 * 60 * 60;
    uint256 constant REWARD_PER_WINDOW = 10;

    constructor(address _tokenAddress) ERC721("Black & White", "BNW") {
        blackToken = BlackToken(_tokenAddress);
    }

    function mint() external payable {
        require(tokenSupply <= MAX_SUPPLY, "supply exhausted");
        _mint(msg.sender, tokenSupply);
        tokenSupply++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmRKoQ8oQJo1Z18ijQowqqB582R2acounQEoARipiPtj9p/";
    }

    /**
     * @dev Stakes `tokenId` token
     *
     * Requirements:
     *
     * - `tokenId` token must exist and be owned by msg sender.
     */
    function stake(uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        require(_msgSender() == owner, "only owner can stake tokens");
        _stake(tokenId);
    }

    /**
     * @dev Unstakes `tokenId` token and trasnfer commission to owner of token.
     *
     * Requirements:
     *
     * - `tokenId` token must exist and be owned by msg sender.
     */
    function withdraw(uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        require(_msgSender() == owner, "only owner can withdraw tokens");

        uint256 amount = _calculateCommission(tokenId);
        blackToken.transfer(_msgSender(), amount);
        _unstake(tokenId);
    }

    /**
     * @dev Mint `amount` ERC20 tokens
     */
    function mintERC20Token(uint256 amount) external {
        blackToken.mint(amount);
    }

    /**
     * @dev Returns whether `tokenId` staked.
     */
    function _isStaked(uint256 tokenId) internal view virtual returns (bool) {
        return stakePool[tokenId] != 0;
    }

    /**
     * @dev Capture `tokenId` token's stake start timestamp.
     */
    function _stake(uint256 tokenId) internal {
        stakePool[tokenId] = block.timestamp;
    }

    /**
     * @dev Clears `tokenId` token's stake start timestamp.
     */
    function _unstake(uint256 tokenId) internal {
        stakePool[tokenId] = 0;
    }

    /**
     * @dev Calculates commission amount for staked `tokenID`
     * In case token is not staked, returns zero.
     */
    function _calculateCommission(uint256 tokenId)
        public
        view
        returns (uint256)
    {
        uint256 stakedTime;
        if (_isStaked(tokenId)) {
            stakedTime = block.timestamp - stakePool[tokenId];
        }

        uint256 commission = (stakedTime / STAKE_WINDOW) * REWARD_PER_WINDOW;
        return commission;
    }
}
