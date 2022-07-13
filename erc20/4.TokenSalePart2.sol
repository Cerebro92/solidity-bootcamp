// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error InsufficientBalance(uint256 available, uint256 required);

contract GDCToken is ERC20 {
    struct ApprovedToken {
        address owner;
        uint256 amount;
    }

    ApprovedToken[] private approvedTokens;
    uint256 public approvedTokensAmount;
    uint256 public contractTokensAmount; /** use contract balance function instead */
    uint256 public currentIndex;

    constructor(uint256 initialSupply) ERC20("GodCoin", "GDC") {
        _mint(msg.sender, initialSupply);
    }

    /** If user transfer token to contract, pay 0.5 ether for every 1000 tokens.
     * check receipient address, If transfering to contract, then check if contract
     * has enough balance to pay for the tokens.
     */
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

    /** If tokens are transferred to contract, then pay sender ethers.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (address(this) == to) {
            contractTokensAmount += amount;
            uint256 requiredEther = requireEthers(amount);
            payable(from).transfer(requiredEther);
        }
    }

    function requireEthers(uint256 amount) internal pure returns (uint256) {
        uint256 requiredEther = (0.5 * 10**18 * amount) / (1000 * 10**18);
        return requiredEther;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);

        if (address(this) == spender) {
            approvedTokensAmount += amount;
            ApprovedToken storage token = approvedTokens.push();
            token.owner = owner;
            token.amount = amount;
        }
        return true;
    }

    function buyTokenFromContract(uint256 amount)
        public
        payable
        returns (bool)
    {
        uint256 requiredEther = requireEthers1(amount);
        require(
            msg.value >= requiredEther,
            "Insufficient ether paid for buying tokens"
        );

        // tranfer from contract tokens.
        // if (contractTokensAmount <= amount){
        //     _transfer(this, msg.sender, amount);
        //     contractTokensAmount -=
        // }
    }

    function requireEthers1(uint256 amount) internal pure returns (uint256) {
        uint256 requiredEther = (1 * 10**18 * amount) / (1000 * 10**18);
        return requiredEther;
    }

    function requiredTokens(uint256 paymentInWei)
        internal
        pure
        returns (uint256)
    {
        uint256 tokens = (1000 * 10**18 * paymentInWei) / 10**18;
        return tokens;
    }

    /** Creates `1000` tokens and assigns them to caller, increasing
     * the total supply.
     *
     * Requirements:
     *
     * - atleast 1 ether payment required.
     * - `totalSupply` should not exceed 1 million.
     */
    function mint(uint256 amount) public payable returns (bool) {
        /*
        step1. mint new tokens.
        step2. transfer from contract tokens.
        step3. transfer from other user's approved tokens.
        */
        uint256 tokens = requiredTokens(msg.value);

        /* step1 */
        if (totalSupply() + tokens < 1000000 * 10**18) {
            _mint(msg.sender, tokens);
            return true;
        }

        /* step2 */
        if (tokens <= contractTokensAmount) {
            _transfer(address(this), msg.sender, tokens);
            contractTokensAmount -= tokens;
            return true;
        }

        _transferFromApprovedTokens(tokens);
        return true;
    }

    function _transferFromApprovedTokens(uint256 tokens)
        private
        returns (bool)
    {
        require(
            tokens <= approvedTokensAmount,
            "Contract does not have enough tokens"
        );

        uint256 totalTokens;
        uint256 requiredWei;
        for (uint256 idx = currentIndex; idx < approvedTokens.length; idx++) {
            uint256 amount = approvedTokens[idx].amount;
            address owner = approvedTokens[idx].owner;

            if (totalTokens + amount >= tokens) {
                uint256 consumedTokens = tokens - totalTokens;
                uint256 amountLeft = amount - consumedTokens;
                approvedTokens[idx].amount = amountLeft;

                requiredWei = requireEthers1(consumedTokens);
                payable(owner).transfer(requiredWei);
                _transfer(owner, msg.sender, consumedTokens);
                _spendAllowance(owner, address(this), consumedTokens);
                currentIndex = idx;
                break;
            }

            requiredWei = requireEthers1(amount);
            payable(owner).transfer(requiredWei);
            _transfer(owner, msg.sender, amount);
            _spendAllowance(owner, address(this), amount);
        }
        return true;
    }
}
