// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {IntraBlockTokenTracking} from "./IntraBlockTokenTracking.sol";
import {IHyperCoreToken} from "./interfaces/IHyperCoreToken.sol";

/// @dev Wallet used to mint coreToken at evm, transferring spot usdc to coreToken's address at spot
contract Wallet is Initializable, IntraBlockTokenTracking {
    /// @dev Core token
    address public immutable coreToken;

    /// @dev Wallet owner (immutable)
    address public owner;

    /// @dev catched when the spot usdc balance is not enough
    error NotEnoughAmount();

    /// @dev cathed for auth error
    error OnlyOwner();

    constructor(address coreToken_) {
        coreToken = coreToken_;
    }

    function initialize(address owner_) external initializer {
        owner = owner_;
    }

    /**
     * @notice Mint token to the owner
     * @param amount amount to mint
     */
    function mintToken(uint64 amount) external {
        _mintToken(owner, amount);
    }

    /**
     * @notice Mint token to the user
     * @param to address to mint the token
     * @param amount amount to mint
     */
    function mintToken(address to, uint64 amount) external {
        _mintToken(to, amount);
    }

    /**
     * @param to user to mint the token
     * @param amount amount to mint
     */
    function _mintToken(address to, uint64 amount) internal onlyOwner {
        // check if there is enough balance at core
        uint64 balance = _getBalance();
        if (amount > balance) revert NotEnoughAmount();

        _spotSend(amount, coreToken);

        // mint HCUSD at evm
        IHyperCoreToken(coreToken).mint(to, amount);
    }

    /**
     * @notice Withdraw USDC from wallet
     * @param amount amount to mint (8 decimals)
     * @param to address to receive the token
     */
    function withdraw(uint64 amount, address to) external onlyOwner {
        _spotSend(amount, to);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }
}
