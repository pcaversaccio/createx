// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

/**
 * @title ImplementationContract
 * @author pcaversaccio
 * @dev Allows to mock a simple `payable` implementation contract for an EIP-1167 minimal proxy contract.
 */
contract ImplementationContract {
    bool public isInitialised;

    /**
     * @dev Error that occurs when the initialisation function has already been called previously.
     * @param emitter The contract that emits the error.
     */
    error IsAlreadyInitialised(address emitter);

    constructor() payable {}

    /**
     * @dev An initialisation function that is called once during deployment.
     */
    function initialiser() external payable {
        if (isInitialised) {
            revert IsAlreadyInitialised(address(this));
        }
        isInitialised = true;
    }
}
