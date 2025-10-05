// SPDX-License-Identifier:  MIT
pragma solidity ^0.8.18;

import {PrecompileLib} from "hyper-evm-lib/PrecompileLib.sol";
import {CoreWriterLib} from "hyper-evm-lib/CoreWriterLib.sol";

abstract contract IntraBlockTokenTracking {
    // usdc amount stored in 8 decimals (supported by evm and core spot)
    uint64 public usedTokenAmounts;
    uint256 lastUsedBlock;

    error IBTT_InvalidAmount();
    error IBTT_InsufficientBalance();

    function _addUsedAmount(uint64 amount) internal {
        if (lastUsedBlock != block.number) {
            usedTokenAmounts = amount;
            lastUsedBlock = block.number;
        } else {
            usedTokenAmounts += amount;
        }
    }

    function _getUsedAmount() internal view returns (uint64) {
        return lastUsedBlock == block.number ? usedTokenAmounts : 0;
    }

    function getBalance() external view returns (uint64) {
        return _getBalance();
    }

    function _getBalance() internal view returns (uint64 balance) {
        PrecompileLib.SpotBalance memory spotBalance = PrecompileLib.spotBalance(address(this), 0);
        uint64 total = spotBalance.total;
        uint64 usedAmount = _getUsedAmount();

        if (usedAmount > total) return 0;
        return total - usedAmount;
    }

    function _spotSend(uint64 amount, address recipient) internal {
        bool activated;
        uint64 balance = _getBalance();

        if (PrecompileLib.coreUserExists(recipient)) {
            activated = true;
        }

        CoreWriterLib.spotSend(recipient, 0, amount);

        // add 1USDC as fee to enable the recipient at core spot
        amount = activated ? amount : amount + 1e8;

        if (amount > balance) revert IBTT_InsufficientBalance();

        _addUsedAmount(amount);
    }
}
