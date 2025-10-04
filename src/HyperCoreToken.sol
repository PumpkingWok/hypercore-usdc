// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "openzeppelin/token/ERC20/ERC20.sol";
import {IWalletFactory} from "./interfaces/IWalletFactory.sol";
import {CoreWriterLib} from "hyper-evm-lib/CoreWriterLib.sol";

contract HyperCoreToken is ERC20("HyperCoreUSDC", "HCUSDC") {

    IWalletFactory public immutable walletFactory;

    error OnlyAccount();

    constructor(address walletFactory_) {
        walletFactory = IWalletFactory(walletFactory_);
    }

    function mint(address account, uint64 amount) external onlyAccount() {
        _mint(account, uint256(amount));
    }

    function burn(uint64 amount, address coreReceiver) external {
        // burn the token at evm
        _burn(msg.sender, uint256(amount)   );

        // send the same amount at core to coreReceiver
        CoreWriterLib.spotSend(coreReceiver, 0, amount);
    }

    modifier onlyAccount() {
        if (!walletFactory.isWallet(msg.sender)) revert OnlyAccount();
        _;
    }
}