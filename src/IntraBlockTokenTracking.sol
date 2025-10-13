// SPDX-License-Identifier:  MIT
pragma solidity ^0.8.18;

import {PrecompileLib} from "hyper-evm-lib/PrecompileLib.sol";
import {CoreWriterLib} from "hyper-evm-lib/CoreWriterLib.sol";

abstract contract IntraBlockTokenTracking {
    /// @dev total amount used in the last block stored
    uint64 public usedTokenAmounts;

    /// @dev last block interaction
    uint256 lastUsedBlock;

    /// @dev trowed at invalid amount
    error IBTT_InvalidAmount();

    /// @dev throwed if the balance is not enough
    error IBTT_InsufficientBalance();

    /// @dev throwed when tries to send zero amount
    error IBTT_ZeroAmount();

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

    /**
     * @notice Send spot token at core
     * @param to destination address
     * @param amount amount to send
     */
    function _spotSend(address to, uint64 amount) internal {
        if (amount == 0) revert IBTT_ZeroAmount();

        bool activated;
        uint64 balance = _getBalance();

        if (PrecompileLib.coreUserExists(to)) {
            activated = true;
        }

        CoreWriterLib.spotSend(to, 0, amount);

        // add 1USDC as fee to enable the recipient at core spot
        amount = activated ? amount : amount + 1e8;

        if (amount > balance) revert IBTT_InsufficientBalance();

        _addUsedAmount(amount);
    }
}
