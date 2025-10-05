// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IWalletFactory {
    function isWallet(address wallet) external view returns (bool);
}
