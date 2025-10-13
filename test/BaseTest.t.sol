// SPDX-License-Identifier:  MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import {MockSpotBalance} from "./mocks/MockSpotBalance.sol";
import {MockCoreUserExists} from "./mocks/MockCoreUserExists.sol";

import {HLConstants} from "hyper-evm-lib/common/HLConstants.sol";

abstract contract BaseTest is Test {
    MockSpotBalance internal spotBalancePrecompile;
    MockCoreUserExists internal coreUserExistsPrecompile;

    function setUp() public virtual {
        vm.createSelectFork("hyperliquid_mainnet");

        _injectPrecompile();
    }

    function _injectPrecompile() internal {
        vm.etch(HLConstants.SPOT_BALANCE_PRECOMPILE_ADDRESS, type(MockSpotBalance).runtimeCode);
        spotBalancePrecompile = MockSpotBalance(HLConstants.SPOT_BALANCE_PRECOMPILE_ADDRESS);

        vm.etch(HLConstants.CORE_USER_EXISTS_PRECOMPILE_ADDRESS, type(MockCoreUserExists).runtimeCode);
        coreUserExistsPrecompile = MockCoreUserExists(HLConstants.CORE_USER_EXISTS_PRECOMPILE_ADDRESS);
    }
}
