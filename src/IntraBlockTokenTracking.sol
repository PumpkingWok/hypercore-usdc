// SPDX-License-Identifier:  MIT
pragma solidity ^0.8.18;

import {PrecompileLib} from "hyper-evm-lib/PrecompileLib.sol";
import {CoreWriterLib} from "hyper-evm-lib/CoreWriterLib.sol";

abstract contract IntraBlockTokenTracking {
    /// @dev total amount used in the last block stored
    uint64 public usedTokenAmounts;

    /// @dev last block interaction
    uint256 lastUsedBlock;

    /// @dev throwed if the balance is not enough
    error IBTT_InsufficientBalance();

    /// @dev throwed when tries to send zero amount
    error IBTT_ZeroAmount();

    /**
     * @notice Get the available balance at the current block state
     */
    function getAvailableBalance() external view returns (uint64) {
        return _getAvailableBalance();
    }

    /**
     * @notice Get the available balance at the current block state
     */
    function _getAvailableBalance() internal view returns (uint64 balance) {
        PrecompileLib.SpotBalance memory spotBalance = PrecompileLib.spotBalance(address(this), 0);
        uint64 total = spotBalance.total;
        uint64 usedAmount = _getUsedAmount();

        // total can't be > usedAmount
        // check on that in the _spotSend()
        return total - usedAmount;
    }

    /**
     * @notice Add amount used in the current block
     */
    function _addUsedAmount(uint64 amount) internal {
        if (lastUsedBlock != block.number) {
            usedTokenAmounts = amount;
            lastUsedBlock = block.number;
        } else {
            usedTokenAmounts += amount;
        }
    }

    /**
     * @notice Get used amount
     */
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

        // enabler fees not included
        CoreWriterLib.spotSend(to, 0, amount);

        // get the balance - used amount in the same block
        uint64 balance = _getAvailableBalance();

        // add 1USDC as fee to enable the recipient at core spot
        amount = PrecompileLib.coreUserExists(to) ? amount : amount + 1e8;

        if (amount > balance) revert IBTT_InsufficientBalance();

        _addUsedAmount(amount);
    }
}
