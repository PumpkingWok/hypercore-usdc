# HyperCoreUSDC
A tool for bridging USDC between HyperLiquid Core and HyperLiquid HyperEVM

## Overview
HyperCoreUSDC enables seamless bridging of USDC between HyperLiquid Core and HyperLiquid HyperEVM. This tool facilitates secure and efficient cross-chain USDC transfers within the HyperLiquid ecosystem.

## How It Works
1. **Deposit Flow (Core to HyperEVM)**
   - Create a Wallet contract using the WalletFactory
   - Top up USDC at your Wallet's address on HyperLiquid Core spot
   - Mint equivalent HyperCore USDC ERC20 token on HyperEVM 

2. **Withdrawal Flow (HyperEVM to Core)**
   - Burn HyperCore USDC on HyperEVM
   - Receive the equivalent USDC back on HyperLiquid Core

## Setup and Testing
```bash
# Install dependencies
forge install

# Run tests
forge test
```

## Usage Steps
1. Deploy a new Wallet using the WalletFactory contract
2. Deposit USDC to your Wallet's address on HyperLiquid Core spot manually.
3. Call the mint function on your Wallet contract to receive HyperCore USDC on HyperEVM
4. To withdraw, call the burn function to receive your USDC back on Core
