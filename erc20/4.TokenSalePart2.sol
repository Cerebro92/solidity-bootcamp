// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error InsufficientBalance(uint256 available, uint256 required);

contract GDCToken is ERC20 {
    address private _manager;
    uint256 private _maxSupply = 1000 * 10**decimals();

    struct ApprovedToken {
        address owner;
        uint256 amount;
    }
    ApprovedToken[] private approvedTokens;
    uint256 public approvedTokensAmount;
    uint256 public currentIndex;

    constructor(uint256 initialSupply) ERC20("GodCoin", "GDC") {
        _manager = _msgSender();
        _mint(_manager, initialSupply);
    }

    /** If user transfer token to contract, pay 0.5 ether for every 1000 tokens.
     * check receipient address, If transfering to contract, then check if contract
     * has enough balance to pay for the tokens.
     */
    function _beforeTokenTransfer(
        address, /* from */
        address to,
        uint256 amount
    ) internal view override {
        if (address(this) == to) {
            uint256 requiredEther = _tokenToWei(amount, 5);
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
            uint256 requiredEther = _tokenToWei(amount, 5);
            payable(from).transfer(requiredEther);
        }
    }

    /** Token to Wei conversino
     */
    function _tokenToWei(uint256 amount, uint256 conversionRate)
        internal
        pure
        returns (uint256)
    {
        uint256 weiRequired = ((conversionRate / 10) * amount * 10**18) /
            (1000 * 10**18);
        return weiRequired;
    }

    /** Wei to token conversino
     */
    function _weiToToken(uint256 paymentInWei) internal pure returns (uint256) {
        uint256 tokens = (paymentInWei * 1000 * 10**18) / 10**18;
        return tokens;
    }

    /**
     * Keep track of tokens approved for spending by contract.
     * TODO Handle scenario where `amount` is maximum `uint256`.
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

    /**
     * step1. if total supply less than threshold, mint new tokens.
     * step2. if contract has enough tokens, transfer from contract tokens,
     * step3. if contract can spend other's token, transfer from approved tokens pool.
     * step4. if not, fail!
     */
    function mint() public payable returns (bool) {
        uint256 tokens = _weiToToken(msg.value);

        /* step1 */
        if (totalSupply() + tokens <= _maxSupply) {
            _mint(msg.sender, tokens);
            return true;
        }

        /* step2 */
        if (tokens <= balanceOf(address(this))) {
            _transfer(address(this), msg.sender, tokens);
            return true;
        }

        /* step3 */
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

        address buyer = _msgSender();
        uint256 totalTokens;
        for (uint256 idx = currentIndex; idx < approvedTokens.length; idx++) {
            uint256 amount = approvedTokens[idx].amount;
            address owner = approvedTokens[idx].owner;

            if (totalTokens + amount >= tokens) {
                uint256 consumedTokens = tokens - totalTokens;
                uint256 amountLeft = amount - consumedTokens;
                approvedTokens[idx].amount = amountLeft;

                _trasferAndPayLender(owner, buyer, consumedTokens);
                currentIndex = idx;
                break;
            }

            _trasferAndPayLender(owner, buyer, amount);
        }
        return true;
    }

    /** Tranfer lended tokens to buyer & pay lender
     */
    function _trasferAndPayLender(
        address lender,
        address buyer,
        uint256 tokens
    ) private returns (bool) {
        uint256 requiredWei = _tokenToWei(tokens, 10);
        payable(lender).transfer(requiredWei);
        _transfer(lender, buyer, tokens);
        _spendAllowance(lender, address(this), tokens);
        return true;
    }

    /** Withdraw ethereum from contract to the owner of contract.
     */
    function withdraw() public returns (bool) {
        address sender = _msgSender();
        require(sender == _manager, "only manager can withdraw from contract");
        payable(_manager).transfer(address(this).balance);
        return true;
    }
}
