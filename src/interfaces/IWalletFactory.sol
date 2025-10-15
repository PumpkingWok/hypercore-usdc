// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IWalletFactory {
    function createWallet(address owner) external returns (address);

    function isWallet(address wallet) external view returns (bool);
}
