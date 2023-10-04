// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

/**
 * @title ImplementationContract
 * @author pcaversaccio
 * @dev Allows to mock a simple `payable` implementation contract for an EIP-1167 minimal proxy contract.
 */
contract ImplementationContract {
    bool public isInitialised;

    constructor() payable {}

    /**
     * @dev An initialisation function that is called once during deployment.
     */
    function initialiser() external payable {
        assert(!isInitialised);
        isInitialised = true;
    }
}
