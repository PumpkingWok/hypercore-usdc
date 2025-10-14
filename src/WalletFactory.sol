// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Clones} from "openzeppelin/proxy/Clones.sol";
import {Wallet} from "./Wallet.sol";
import {HyperCoreUsdc} from "./HyperCoreUsdc.sol";
import {IWalletFactory} from "./interfaces/IWalletFactory.sol";

/// @notice Wallet factory (it deploys the hyperCoreUsdc token and the wallet impl)
contract WalletFactory is IWalletFactory {
    /// @dev Wallet implementation contract
    address public immutable WALLET;

    /// @dev take trace of wallets
    mapping(address => bool) public isWallet;

    /// @dev Emitted when a new wallet is deployed
    event WalletCreated(address user, address wallet);

    constructor() {
        // deploy the core token (it won't be stored here)
        address hyperCoreUsdc = address(new HyperCoreUsdc(address(this)));
        // deploy the wallet impl
        WALLET = address(new Wallet(hyperCoreUsdc));
    }

    /**
     * @notice Create a new Wallet for a user
     * @dev Deploy a new proxy wallet, initializing it
     * @param owner Wallet owner (immutable)
     * @return wallet The address of the newly created wallet
     */
    function createWallet(address owner) external returns (address wallet) {
        // deploy a new wallet
        wallet = Clones.clone(WALLET);
        Wallet(wallet).initialize(owner);

        isWallet[wallet] = true;

        emit WalletCreated(owner, wallet);
    }
}
