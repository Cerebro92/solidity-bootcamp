# Black & White NFT - with Staking features

Smart contracts demonstrates staking of NFT tokens and ERC20 tokens in reward.

#### How to deploy?

1. Deploy BlackToken contract and get the contract's address.
2. Use BlackToken contract address to deploy a BlackNFT contract.

#### How to stake and earn reward using Black & White tokens?

1. Setup - use `mintERC20Token` function to mint ERC20 tokens. This transfer `amount` ERC20 token to BlackNFT contract address.
2. Mint a new `BNW` token using BlackNFT smart contract.
3. Stake minted token to the contract.
4. Withdraw token. This unstakes token and transfer reward (ERC20 tokens) to the owner address.
