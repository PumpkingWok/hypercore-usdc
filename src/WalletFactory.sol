// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Clones} from "openzeppelin/proxy/Clones.sol";

import {IWalletFactory} from "./interfaces/IWalletFactory.sol";

import {HyperCoreUsdc} from "./HyperCoreUsdc.sol";
import {Wallet} from "./Wallet.sol";

/// @notice Wallet factory (it deploys the hyperCoreUsdc token and the wallet impl within constructor)
contract WalletFactory is IWalletFactory {
    /// @dev Wallet implementation contract
    address public immutable WALLET;

    /// @dev Take trace of wallets created
    mapping(address => bool) public isWallet;

    /// @dev owner (immutable) => wallet
    mapping(address => address) public wallets;

    /// @dev Thrown when an owner already owns a wallet
    error WF_OneWalletPerOwner();

    /// @dev Emitted when a new wallet is deployed
    event WalletCreated(address owner, address wallet);

    constructor() {
        // deploy the hyperCoreUsdc token and wallet impl
        WALLET = address(new Wallet(address(new HyperCoreUsdc(address(this)))));
    }

    /**
     * @notice Create a new Wallet for a user
     * @dev Deploy a new proxy wallet, initializing it
     * @param owner wallet owner (immutable)
     * @return wallet address of the newly created wallet
     */
    function createWallet(address owner) external returns (address wallet) {
        if (wallets[owner] != address(0)) revert WF_OneWalletPerOwner();
        // deploy a new wallet
        wallet = Clones.clone(WALLET);
        Wallet(wallet).initialize(owner);

        isWallet[wallet] = true;
        wallets[owner] = wallet;

        emit WalletCreated(owner, wallet);
    }
}
