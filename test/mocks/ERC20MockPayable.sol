// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";

/**
 * @title ERC20MockPayable
 * @author pcaversaccio
 * @notice Forked and adjusted accordingly from here:
 * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/mocks/token/ERC20Mock.sol.
 * @dev Allows to mock a simple `payable` ERC-20 implementation.
 */
contract ERC20MockPayable is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_,
        address initialAccount_,
        uint256 initialBalance_
    ) payable ERC20(name_, symbol_) {
        _mint({account: initialAccount_, value: initialBalance_});
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`.
     * @param account The 20-byte account address.
     * @param amount The 32-byte token amount to be created.
     */
    function mint(address account, uint256 amount) public payable {
        _mint({account: account, value: amount});
    }

    /**
     * @dev Destroys `amount` tokens from `account`.
     * @param account The 20-byte account address.
     * @param amount The 32-byte token amount to be destroyed.
     */
    function burn(address account, uint256 amount) public payable {
        _burn({account: account, value: amount});
    }
}
