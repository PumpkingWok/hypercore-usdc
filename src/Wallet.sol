// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {IntraBlockTokenTracking} from "./IntraBlockTokenTracking.sol";
import {IHyperCoreToken} from "./interfaces/IHyperCoreToken.sol";

contract Wallet is Initializable, IntraBlockTokenTracking {
  /// @dev Core token
  IHyperCoreToken public immutable coreToken;
  address public owner;

  /// @dev 
  error NotEnoughAmount();

  /// @dev OnlyOwner
  error OnlyOwner();

  constructor(address coreToken_) {
    coreToken = IHyperCoreToken(coreToken_);
  }

  function initialize(address owner_) external initializer {
    owner = owner_;
  }

  // Deposit to subAccounts
  // amount in 8 decimals
  /** 
   * @param user user to mint token for
   * @param amount amount to mint
   */
  function mintToken(address user, uint64 amount) external onlyOwner {
    // check if there is enough balance at core
    uint64 balance = _getBalance();
    if (amount > balance) revert NotEnoughAmount();

    _spotSend(amount, user);

    // mint HCUSD at evm
    coreToken.mint(user, amount);
  }

  // Withdraw USDC from wallet
  // amount in 8 decimals
  function withdraw(uint64 amount, address recipient) external onlyOwner {
    _spotSend(amount, recipient);
  }

  modifier onlyOwner() {
    if (msg.sender != owner) revert OnlyOwner();
    _;
  }
}
