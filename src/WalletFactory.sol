// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Clones} from "openzeppelin/proxy/Clones.sol";
import {Wallet} from "./Wallet.sol";
import {HyperCoreToken} from "./HyperCoreToken.sol";

/// @notice TokenWallet factory
contract WalletFactory {
    /// @dev Wallet implementation contract
    address public immutable WALLET;

    /// @dev take trace of wallets
    mapping(address => bool) public isWallet;

    /// @dev Emitted when a new wallet is deployed
    event WalletCreated(address user, address wallet);

    constructor() {
        // deploy the core token (it won't be stored here)
        address hyperCoreToken = address(new HyperCoreToken(address(this)));
        // deploy the wallet impl
        WALLET = address(new Wallet(hyperCoreToken));
    }

    /**
     * @notice Create a new Wallet for a user
     * @dev Deploy a new proxy wallet, initializing it
     * @return wallet The address of the newly created wallet
     */
    function createWallet(address user) external returns (address wallet) {
        // deploy a new wallet
        wallet = Clones.clone(WALLET);
        Wallet(wallet).initialize(user);

        isWallet[wallet] = true;

        emit WalletCreated(user, wallet);
    }
}
