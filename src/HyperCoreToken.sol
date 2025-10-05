// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {IWalletFactory} from "./interfaces/IWalletFactory.sol";
import {CoreWriterLib} from "hyper-evm-lib/CoreWriterLib.sol";

/// @notice ERC20 token representation at evm of USDC core spot
/// Only the Wallet created via the WalletFactory can mint token, at 1:1 rate, transferring USDC to the token address at core
/// On burning side, anyone can do it and the same amount at 1:1 rate will be receive at core
contract HyperCoreToken is ERC20("HyperCoreUSDC", "HCUSDC") {
    /// @dev Wallet factory
    IWalletFactory public immutable walletFactory;

    /// @dev Throwed when a non wallet try to mint
    error OnlyWallet();

    constructor(address walletFactory_) {
        walletFactory = IWalletFactory(walletFactory_);
    }

    /**
     * @notice Mint token to the user
     * @param to address to mint the token
     * @param amount amount to mint
     */
    function mint(address to, uint64 amount) external onlyWallet {
        _mint(to, uint256(amount));
    }

    /**
     * @notice Burn token
     * @param amount amount to burn
     * @param coreReceiver address to receive the token at core spot
     */
    function burn(uint64 amount, address coreReceiver) external {
        // burn the token at evm
        _burn(msg.sender, uint256(amount));

        // send the same amount at core to coreReceiver
        CoreWriterLib.spotSend(coreReceiver, 0, amount);
    }

    /**
     * @notice Token decimals 8 as usdc
     */
    function decimals() public view override returns (uint8) {
        return 8;
    }

    modifier onlyWallet() {
        if (!walletFactory.isWallet(msg.sender)) revert OnlyWallet();
        _;
    }
}
