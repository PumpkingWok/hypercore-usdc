// SPDX-License-Identifier:  MIT
pragma solidity 0.8.28;

import {BaseTest} from "./BaseTest.t.sol";
import {Wallet} from "src/Wallet.sol";
import {WalletFactory} from "src/WalletFactory.sol";
import {HyperCoreUsdc} from "src/HyperCoreUsdc.sol";

contract WalletTest is BaseTest {
    WalletFactory public factory;
    HyperCoreUsdc public hcUsdc;
    Wallet public wallet;

    address user = address(0xABBB);

    uint64 spotBalanceOnCore = 1e8;

    function setUp() public override {
        super.setUp();

        // deploy factory
        factory = new WalletFactory();
        wallet = Wallet(factory.createWallet(user));
        hcUsdc = HyperCoreUsdc(wallet.CORE_TOKEN());

        _setCore();
    }

    function testDeploy() external {
        assertEq(wallet.owner(), user);

        assertEq(factory.isWallet(address(wallet)), true);

        assertEq(address(hcUsdc.WALLET_FACTORY()), address(factory));
        assertEq(hcUsdc.decimals(), 8);
    }

    function testMint() external {
        uint64 amountToMint = 1e8;

        uint256 balanceBefore = hcUsdc.balanceOf(user);
        assertEq(balanceBefore, 0);

        assertEq(wallet.lastUsedBlock(), 0);

        _mintToken(amountToMint);

        uint256 balanceAfter = hcUsdc.balanceOf(user);
        assertEq(balanceAfter - balanceBefore, amountToMint);

        assertEq(wallet.lastUsedBlock(), block.number);
    }

    function testMintToRecipient() external {
        address recipient = address(0xABBB);

        uint256 balanceBefore = hcUsdc.balanceOf(recipient);

        vm.prank(user);
        wallet.mintToken(recipient, spotBalanceOnCore);

        uint256 balanceAfter = hcUsdc.balanceOf(recipient);
        assertEq(balanceAfter - balanceBefore, spotBalanceOnCore);
    }

    function testMintBurnSameBlock() external {
        uint64 amount = 1e8;

        _mintToken(amount);

        coreUserExistsPrecompile.setCoreUserExists(user, true);
        vm.prank(user);
        hcUsdc.burn(user, amount);

        assertEq(hcUsdc.balanceOf(user), 0);
        assertEq(hcUsdc.totalSupply(), 0);
    }

    function testTwoMintSameBlock() external {
        _mintToken(spotBalanceOnCore / 2);

        vm.expectRevert(Wallet.W_OneActionPerBlock.selector);
        _mintToken(spotBalanceOnCore / 2);
    }

    function testBurnReceiverNotEnabled() external {}

    function _mintToken(uint64 amount) internal {
        vm.prank(user);
        wallet.mintToken(amount);
    }

    function _setCore() internal {
        coreUserExistsPrecompile.setCoreUserExists(address(hcUsdc), true);
        spotBalancePrecompile.setSpotBalance(address(wallet), 0, spotBalanceOnCore, 0, 0);
    }
}
