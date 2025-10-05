// SPDX-License-Identifier:  MIT
pragma solidity ^0.8.18;

import {HLConstants} from "hyper-evm-lib/common/HLConstants.sol";

import {BaseTest} from "./BaseTest.t.sol";
import {Wallet} from "src/Wallet.sol";
import {WalletFactory} from "src/WalletFactory.sol";
import {HyperCoreToken} from "src/HyperCoreToken.sol";

contract WalletTest is BaseTest {
    WalletFactory public factory;
    HyperCoreToken public hcUsdc;
    Wallet public wallet;

    address user = address(0xABBB);

    uint64 spotBalanceOnCore = 1e8;

    function setUp() public override {
        super.setUp();

        // deploy factory
        factory = new WalletFactory();
        wallet = Wallet(factory.createWallet(user));
        hcUsdc = HyperCoreToken(wallet.coreToken());

        _setCore();
    }

    function testCreateWallet() external {
        assertEq(wallet.owner(), user);
    }

    function testMint() external {
        uint64 amountToMint = 1e8;

        uint256 balanceBefore = hcUsdc.balanceOf(user);
        assertEq(balanceBefore, 0);

        vm.prank(user);
        wallet.mintToken(amountToMint);

        uint256 balanceAfter = hcUsdc.balanceOf(user);
        assertEq(balanceAfter - balanceBefore, amountToMint);
    }

    function testMintBurnSameBlock() external {
        uint64 amount = 1e8;

        vm.startPrank(user);
        wallet.mintToken(amount);
        hcUsdc.burn(amount, user);

        assertEq(hcUsdc.balanceOf(user), 0);
    }

    function _setCore() internal {
        coreUserExistsPrecompile.setCoreUserExists(address(hcUsdc), true);
        spotBalancePrecompile.setSpotBalance(address(wallet), 0, spotBalanceOnCore, 0, 0);
    }
}
