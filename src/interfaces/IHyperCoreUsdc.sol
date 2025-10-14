// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IHyperCoreUsdc {
    function burn(address coreReceiver, uint64 amount) external;

    function mint(address to, uint64 amount) external;
}
