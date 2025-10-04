// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Clones} from "openzeppelin/proxy/Clones.sol";
import {Wallet} from "./Wallet.sol";
//import "openzeppelin/token/ERC721/ERC721.sol";
import "openzeppelin/access/Ownable2Step.sol";

/// @notice TokenWallet factory
contract WalletFactory is Ownable2Step {
    ///////////////
    // Variables //
    ///////////////

    /// @dev Wallet implementation contract
    address public immutable WALLET;
    
    /// @dev take trace of wallets 
    mapping (address => bool) public isWallet;

    ///////////////
    // Events //
    ///////////////

    /// @dev Emitted when a new wallet is deployed
    event WalletCreated(address user, address wallet);

    constructor(address hyperCoreToken_, address owner_) Ownable(owner_) {
        WALLET = address(new Wallet(hyperCoreToken_));
    }

    /**
     * @notice Creates a new Wallet for a user
     * @dev Deploys a new proxy wallet, initializing it
     * @return wallet The address of the newly created wallet
     */
    function createWallet(address user) external returns (address wallet) {
        // deploy a new account contract
        wallet = Clones.clone(WALLET);
        Wallet(payable(wallet)).initialize(user);

        isWallet[wallet] = true;

        emit WalletCreated(user, wallet);
    }
}
