// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {IWalletFactory} from "./interfaces/IWalletFactory.sol";
import {CoreWriterLib} from "hyper-evm-lib/CoreWriterLib.sol";
import {PrecompileLib} from "hyper-evm-lib/PrecompileLib.sol";

/// @notice ERC20 token representation at evm of USDC core spot
/// Only the Wallet created via the WalletFactory can mint token, at 1:1 rate, transferring USDC to the token address at core
/// On burning side, any token holder can call it to burn them at 1:1 rate, the same amount will be receive at core
contract HyperCoreToken is ERC20("HyperCoreUSDC", "HCUSDC") {
    /// @dev Wallet factory
    IWalletFactory public immutable walletFactory;

    /// @dev Core enabler fee (1 USDC)
    uint64 public constant ENABLER_FEE = 1e8;

    /// @dev Throwed when the amount to send is not enough to cover enabler fee
    error HCT_AmountLessThanFee();

    /// @dev Throwed when a non wallet try to mint
    error HCT_OnlyWallet();

    /// @dev Throwed if the burning receiver is not enabled at core
    error HCT_ReceiverNotEnabled();

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

        // edge case when an account is enabled within the same block
        // in a tx executed before it
        if (!PrecompileLib.coreUserExists(coreReceiver)) {
            if (amount <= ENABLER_FEE) revert HCT_AmountLessThanFee();
            amount -= ENABLER_FEE;
        }

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
        if (!walletFactory.isWallet(msg.sender)) revert HCT_OnlyWallet();
        _;
    }
}
