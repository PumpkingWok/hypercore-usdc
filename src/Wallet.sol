// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {IntraBlockTokenTracking} from "./IntraBlockTokenTracking.sol";
import {IHyperCoreToken} from "./interfaces/IHyperCoreToken.sol";

/// @dev Wallet used to mint coreToken at evm, transferring spot usdc to coreToken's address at spot
contract Wallet is Initializable, IntraBlockTokenTracking {
    /// @dev Core token
    address public immutable CORE_TOKEN;

    /// @dev Wallet owner (immutable)
    address public owner;

    /// @dev catched when the spot usdc balance is not enough
    error W_NotEnoughAmount();

    /// @dev cathed for auth error
    error W_OnlyOwner();

    /// @dev emitted at mint
    event Mint(address indexed to, uint64 amount);

    /// @dev emitted when a user withdraw
    event Withdraw(address indexed to, uint64 amount);

    constructor(address coreToken_) {
        CORE_TOKEN = coreToken_;
    }

    /**
     * @notice Initialize function
     * @param owner_ Wallet owner
     */
    function initialize(address owner_) external initializer {
        owner = owner_;
    }

    /**
     * @notice Mint token to the wallet's owner
     * @param amount amount to mint
     */
    function mintToken(uint64 amount) external {
        _mintToken(owner, amount);
    }

    /**
     * @notice Mint token to the user
     * @param to address to mint the token for
     * @param amount amount to mint
     */
    function mintToken(address to, uint64 amount) external {
        _mintToken(to, amount);
    }

    /**
     * @param to user to mint the token for
     * @param amount amount to mint
     */
    function _mintToken(address to, uint64 amount) internal onlyOwner {
        // transfer token to coreToken address at core
        // assume core token is enabled at core
        _spotSend(CORE_TOKEN, amount);

        // mint token at evm
        IHyperCoreToken(CORE_TOKEN).mint(to, amount);

        emit Mint(to, amount);
    }

    /**
     * @notice Withdraw USDC from wallet
     * @param amount amount to withdraw (8 decimals)
     * @param to address to receive the token
     */
    function withdraw(address to, uint64 amount) external onlyOwner {
        _spotSend(to, amount);

        emit Withdraw(to, amount);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert W_OnlyOwner();
        _;
    }
}
